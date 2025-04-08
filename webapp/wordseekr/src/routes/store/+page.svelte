<script lang="ts">
	import BalanceCard from '$lib/components/Store/BalanceCard.svelte';
	import StoreProductCard from '$lib/components/Store/StoreProductCard.svelte';
	import RemoveAdsPage from '../remove-ads/+page.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import {
		productsStore,
		purchasesStore,
		PRODUCT_IDS,
		COIN_PACKS_META
	} from '$lib/economy/iapStore';

	import { closeModal, openModal } from '$lib/components/shared/ModalHost';

	function handleRemoveAds() {
		openModal(RemoveAdsPage, {
			close: () => {
				console.log('closeModal');
				closeModal();
			}
		});
	}

	interface Product {
		id: string;
		name: string;
		coins: number;
		price: string | undefined;
		productId: string;
		callout?: string;
		isCalloutRed?: boolean;
		type: 'iap' | 'ad';
	}

	const coinPacksIDs: string[] = [
		PRODUCT_IDS.COIN_PACK_SMALL,
		PRODUCT_IDS.COIN_PACK_MEDIUM,
		PRODUCT_IDS.COIN_PACK_LARGE,
		PRODUCT_IDS.COIN_PACK_HUGE
	];

	let coinPacks: Product[] = [];
	console.log('productsStore', productsStore);
	productsStore.subscribe((products) => {
		console.log('coinPacksIDs', coinPacksIDs);
		const p = Object.values(products);
		console.log('products', p);
		console.log('COIN_PACKS_META', COIN_PACKS_META);
		coinPacks = Object.values(products)
			.filter((product) => coinPacksIDs.includes(product.id))
			.map((product) => {
				console.log('product', product);
				const meta = COIN_PACKS_META[product.id];
				console.log('meta', meta);
				return {
					id: product.id,
					name: meta.title,
					coins: meta.coins,
					price: product.displayPrice,
					productId: product.id,
					callout: meta.callout,
					isCalloutRed: meta.isCalloutRed,
					type: 'iap'
				} as Product;
			});
	});

	const rewardedAdProducts: Product[] = [
		{
			id: 'REWARDED_AD',
			name: 'Get Free Coins',
			coins: 100,
			price: undefined,
			productId: PRODUCT_IDS.REMOVE_ADS,
			type: 'ad'
		}
	];

	function handleProductClick(product: Product) {
		if (product.type === 'iap') {
			buyProduct(product);
		} else {
			watchAd(product);
		}
	}

	function buyProduct(product: Product) {
		const productId = product.productId;
		purchasesStore
			.makePurchase(productId)
			.then(() => {
				walletStore.addCoins(product.coins);
			})
			.catch((error) => {
				console.error(`Failed to purchase ${productId}:`, error);
			});
	}

	function watchAd(product: Product) {
		// This would integrate with your ad system
		console.log('Watch ad for rewards');
		walletStore.addCoins(100);
	}
	let removeAds = $state(false);
	walletStore.removeAds((removeAds) => {
		console.log('removeAds', removeAds);
		removeAds = removeAds;
	});
</script>

<div class="h-svh bg-white select-none">
	<div class="flex flex-col items-stretch gap-2 p-4">
		<span class="self-center text-2xl font-bold">Store</span>
		<BalanceCard />
		{#if !removeAds}
			<StoreProductCard
				title="Ad-Free Experience"
				detail="Remove all ads permanently"
				isIndicatorActive={true}
				onclick={handleRemoveAds}
				callout="Limited Time"
				isRemoveAds={true}
				isCalloutRed={true}
				isCalloutAnimating={true}
			/>
		{/if}

		<span class="text-xl font-bold">Coins</span>
		{#each coinPacks as product}
			<StoreProductCard
				title={product.name}
				detail={`${product.coins} coins`}
				callout={product.callout}
				price={product.price}
				isCalloutRed={product.isCalloutRed}
				onclick={() => handleProductClick(product)}
			/>
		{/each}
		{#each rewardedAdProducts as product}
			<StoreProductCard
				title={product.name}
				detail={`${product.coins} coins`}
				isCalloutRed={false}
				onclick={() => handleProductClick(product)}
			/>
		{/each}
	</div>
</div>
