<script lang="ts">
	import LoadSpinner from '$lib/components/shared/LoadSpinner.svelte';

	import BalanceCard from '$lib/components/Store/BalanceCard.svelte';
	import StoreProductCard from '$lib/components/Store/StoreProductCard.svelte';
	import RemoveAdsPage from '../remove-ads/+page.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import {
		productsStore,
		purchasesStore,
		PRODUCT_IDS,
		COIN_PACKS_META,
		isIAPAvailable
	} from '$lib/economy/iapStore';

	import { closeModal, openModal } from '$lib/components/shared/ModalHost';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { onDestroy, onMount } from 'svelte';
	import { analytics } from '$lib/analytics/analytics';
	import Modal from '$lib/components/Modal.svelte';
	import { VList } from 'virtua/svelte';
	import { animate, eases, utils } from 'animejs';

	interface Props {
		onClose: () => void;
	}
	const { onClose } = $props();

	onDestroy(() => {
		analytics.storedClosed();
	});

	function handleRemoveAds() {
		openModal(RemoveAdsPage, {
			close: () => {
				console.log('closeModal');
				closeModal();
			}
		});
	}

	let isActive = $state(false);
	let isLoading = $state(false);
	interface Product {
		id: string;
		name: string;
		detail: string;
		coins: number;
		price: string | undefined;
		productId: string;
		callout?: string;
		isCalloutRed?: boolean;
		isRemoveAds?: boolean;
		type: 'iap' | 'ad';
	}

	const coinPacksIDs: string[] = [
		PRODUCT_IDS.COIN_PACK_SMALL,
		PRODUCT_IDS.COIN_PACK_MEDIUM,
		PRODUCT_IDS.COIN_PACK_LARGE,
		PRODUCT_IDS.COIN_PACK_HUGE
	];

	let coinPacks: Product[] = $state([]);

	productsStore.subscribe((products) => {
		coinPacks = Object.values(products)
			.filter((product) => coinPacksIDs.includes(product.id))
			.map((product) => {
				const meta = COIN_PACKS_META[product.id];
				return {
					id: product.id,
					name: meta.title,
					detail: `${meta.coins} coins`,
					coins: meta.coins,
					price: product.displayPrice,
					productId: product.id,
					callout: meta.callout,
					isCalloutRed: meta.isCalloutRed,
					type: 'iap'
				} as Product;
			});
	});
	let showRemoveAds = $state(false);
	let isRewardedAdAvailable = $state(false);

	const rewardedAdProducts: Product[] = $derived(
		isRewardedAdAvailable
			? [
					{
						id: 'REWARDED_AD',
						name: 'Free Coins',
						detail: '50 coins',
						coins: 50,
						price: undefined,
						productId: PRODUCT_IDS.REMOVE_ADS,
						type: 'ad'
					}
				]
			: []
	);

	let removeAdsProduct: Product | undefined = $derived(
		isActive && showRemoveAds
			? {
					id: 'REMOVE_ADS',
					name: 'Ad-Free Experience',
					detail: 'Remove all ads permanently',
					coins: 0,
					price: undefined,
					productId: PRODUCT_IDS.REMOVE_ADS,
					isRemoveAds: true,
					type: 'iap'
				}
			: undefined
	);
	let products: Product[] = $derived(
		[removeAdsProduct, ...coinPacks, ...rewardedAdProducts].filter(
			(product) => product !== undefined
		)
	);
	function handleProductClick(product: Product) {
		if (product.type === 'iap') {
			buyProduct(product);
		} else {
			watchAd(product);
		}
	}

	function buyProduct(product: Product) {
		const productId = product.productId;
		isLoading = true;
		purchasesStore
			.makePurchase(productId)
			.then((success) => {
				if (success) {
					isLoading = false;
					setTimeout(() => {
						animateCoins(product.id, () => {
							walletStore.addCoins(product.coins);
						});
					}, 1);
				} else {
					isLoading = false;
				}
			})
			.catch((error) => {
				console.error(`Failed to purchase ${productId}:`, error);
			})
			.finally(() => {
				isLoading = false;
			});
	}

	function animateCoins(coinId: string, onGiveReward: () => void) {
		const original = document.getElementById(coinId);
		const balanceTagIcon = document.getElementById('balance-tag-icon');

		if (!original || !balanceTagIcon) {
			return;
		}
		const rect = original.getBoundingClientRect();
		const coinsPileIcon = original.cloneNode(true) as HTMLElement;
		coinsPileIcon.removeAttribute('id');
		Object.assign(coinsPileIcon.style, {
			position: 'fixed',
			left: `${rect.left}px`,
			top: `${rect.top}px`,
			width: `${rect.width}px`,
			height: `${rect.height}px`,
			margin: 0,
			zIndex: 9999,
			pointerEvents: 'none' // prevent accidental clicks
		});
		utils.set(coinsPileIcon, {
			opacity: 1
		});

		const balanceTagRect = balanceTagIcon.getBoundingClientRect();

		const translateX = balanceTagRect.left - rect.left;
		const translateY = balanceTagRect.top - rect.top;

		document.body.appendChild(coinsPileIcon);
		const animationDuration = 1000;
		animate(coinsPileIcon, {
			translateX,
			ease: 'in',
			duration: animationDuration
		});
		animate(coinsPileIcon, {
			translateY,
			ease: 'out',
			duration: animationDuration
		});
		animate(coinsPileIcon, {
			opacity: [1, 1, 0],
			scale: [1, 0.5, 0],
			ease: 'inOut',
			delay: animationDuration / 2,
			duration: animationDuration / 2
		}).then(() => {
			onGiveReward?.();
			coinsPileIcon.remove();
		});
	}

	async function watchAd(product: Product) {
		// This would integrate with your ad system
		console.log('Watch ad for rewards');
		isLoading = true;
		try {
			const watched = await adStore.showAd(AdType.Rewarded, null);
			// const watched = await mockWatchAd(product);
			if (watched) {
				setTimeout(() => {
					animateCoins(product.id, () => {
						walletStore.addCoins(100);
					});
				}, 150);
			}
		} catch (error) {
			console.error(`Failed to watch ad:`, error);
		}
		isLoading = false;
	}

	onMount(async () => {
		isActive = await isIAPAvailable();
		adStore.getAdLoadingState(AdType.Rewarded).subscribe((isLoaded) => {
			isRewardedAdAvailable = isLoaded;
		});
		walletStore.removeAds((removeAds) => {
			showRemoveAds = !removeAds;
		});
	});
</script>

<Modal {onClose} backgroundOpacity={50} onDismiss={onClose} canDismissOnBackground={true}>
	<div class="flex max-h-[75svh] w-full flex-col items-center justify-start gap-4">
		<div class="flex w-2xs flex-col items-stretch gap-3">
			<span class="self-center text-2xl font-bold">Store</span>
			<div
				class="mt-2 flex max-h-[75svh] w-full min-w-full flex-col items-stretch justify-center gap-2"
			>
				<VList
					data={products}
					style="height: {isActive
						? showRemoveAds
							? '60svh'
							: '51vh'
						: '90px'}; -webkit-overflow-scrolling: touch; scrollbar-width: none; -ms-overflow-style: none;"
				>
					{#snippet children(product)}
						<div class="relative mb-4">
							<StoreProductCard
								iconId={product.id}
								title={product.name}
								detail={product.detail}
								callout={product.callout}
								price={product.price}
								isCalloutRed={product.isCalloutRed}
								isIndicatorActive={product.isRemoveAds}
								onclick={() =>
									product.isRemoveAds ? handleRemoveAds() : handleProductClick(product)}
								isRemoveAds={product.isRemoveAds}
							/>
						</div>
					{/snippet}
				</VList>
			</div>
		</div>

		{#if isLoading}
			<LoadSpinner />
		{/if}
	</div>
</Modal>
