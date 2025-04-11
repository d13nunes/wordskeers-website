<script lang="ts">
	import { onMount } from 'svelte';
	import { productsStore, purchasesStore, PRODUCT_IDS, adsRemoved } from '$lib/economy/iapStore';

	let price = $state('');
	onMount(() => {
		// Load the actual price from the store
		const removeAdsProduct = $productsStore[PRODUCT_IDS.REMOVE_ADS];
		if (removeAdsProduct) {
			price = removeAdsProduct.displayPrice;
		}
	});

	interface Props {
		close: () => void;
	}

	const { close }: Props = $props();

	function buyRemoveAds() {
		purchasesStore
			.makePurchase(PRODUCT_IDS.REMOVE_ADS_DISCOUNT)
			.then(() => {
				// Success will be handled by the store listener
				console.log('Purchase initiated');
				// TODO: Show a success message
				close();
			})
			.catch((error) => {
				console.error('Failed to purchase remove ads:', error);
			});
	}

	function restore() {
		// Handle restoring purchases
		purchasesStore
			.restore()
			.then(() => {
				console.log('Purchases restored');
			})
			.catch((error) => {
				console.error('Failed to restore purchases:', error);
			});
	}
	let isRestoreAvailable = purchasesStore.isRestoreAvailable();
</script>

<!-- Header -->

<div class="relative flex w-full flex-col bg-white select-none">
	<!-- Main Content -->
	<button
		class="text-md absolute top-4 left-4 font-normal text-blue-500 active:text-blue-800"
		onclick={close}
	>
		Close
	</button>

	{#if isRestoreAvailable}
		<button
			class="text-md absolute top-4 right-4 font-normal text-blue-500 active:text-blue-800"
			onclick={restore}
		>
			Restore
		</button>
	{/if}

	<div class=" flex-1 justify-items-center px-4 pt-16 max-[24rem]:pt-10">
		<p
			class="text-3xl font-bold max-[24rem]:-mb-1 max-[24rem]:text-center max-[24rem]:text-lg sm:text-xl"
		>
			Ad-Free Experience
		</p>
		<p
			class="mb-4 text-xl text-gray-500 max-[24rem]:mb-2 max-[24rem]:text-center max-[24rem]:text-sm"
		>
			Remove all ads permanently
		</p>

		<!-- Offer Box -->
		<div class="mb-8 rounded-xl bg-gray-50 p-6 max-[24rem]:p-3">
			<div class="">
				<p class="text-xl font-semibold max-[24rem]:text-lg">🎉 Limited-Time Offer! 🎉</p>
				<p class="text-base font-normal max-[24rem]:text-sm">
					Enjoy a seamless, ad-free experience. Now at an exclusive early bird discount!
				</p>
				<p class="text-base font-normal">Act now! Offer available for a limited period only.</p>
			</div>

			<!-- Benefits Section -->
			<div class="mt-2">
				<h3 class="mb-1 text-2xl font-semibold max-[24rem]:text-lg">Benefits</h3>
				<ul class="space-y-0">
					<li class="max-[24rem]:text-tiny flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">No more interruptions</span>
					</li>
					<li class="max-[24rem]:text-tiny flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Ad-free gameplay</span>
					</li>
					<li class="max-[24rem]:text-tiny flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Faster loading times</span>
					</li>
					<li class="max-[24rem]:text-tiny flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">One-time purchase</span>
					</li>
					<li class="max-[24rem]:text-tiny flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Supports future development</span>
					</li>
				</ul>
			</div>
		</div>
	</div>

	<!-- Purchase Button -->
	<div class="p-4 max-[24rem]:p-2">
		{#if $adsRemoved}
			<button class="w-full rounded-xl bg-green-700 py-4 text-white max-[24rem]:py-2">
				<span class="text-xl font-semibold">✓ Ads Removed!</span>
			</button>
		{:else}
			<button
				class="relative w-full rounded-xl bg-blue-700 py-4 text-white active:bg-blue-800 max-[24rem]:py-2"
				onclick={buyRemoveAds}
			>
				<span class="absolute left-4 rounded-md bg-red-700 px-2 py-1 text-sm text-white"
					>60% Off</span
				>
				<span class="text-xl font-semibold">{price}</span>
			</button>
		{/if}
	</div>
</div>

<style>
	/* Add any additional custom styles here if needed */
</style>
