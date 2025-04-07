<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import { productsStore, purchasesStore, PRODUCT_IDS, adsRemoved } from '$lib/economy/iapStore';

	let price = '3.99 €'; // Default price

	onMount(() => {
		// Load the actual price from the store
		if ($productsStore[PRODUCT_IDS.REMOVE_ADS]) {
			price = $productsStore[PRODUCT_IDS.REMOVE_ADS].displayPrice;
		}
	});

	function close() {
		goto('/store');
	}

	function buyRemoveAds() {
		purchasesStore
			.makePurchase(PRODUCT_IDS.REMOVE_ADS)
			.then(() => {
				// Success will be handled by the store listener
				console.log('Purchase initiated');
			})
			.catch((error) => {
				console.error('Failed to purchase remove ads:', error);
			});
	}

	function restore() {
		// Handle restoring purchases
		purchasesStore
			.initializePurchases()
			.then(() => {
				console.log('Purchases restored');
			})
			.catch((error) => {
				console.error('Failed to restore purchases:', error);
			});
	}
</script>

<!-- Header -->

<div class="relative flex h-svh w-svw flex-col bg-white">
	<!-- Main Content -->
	<button class="text-md absolute top-4 left-4 font-normal text-blue-500" on:click={close}>
		Close
	</button>

	<div class=" flex-1 justify-items-center px-6 pt-16">
		<h class="mb-2 text-3xl font-bold">Ad-Free Experience</h>
		<p class="mb-4 text-xl text-gray-500">Remove all ads permanently</p>

		<!-- Offer Box -->
		<div class="mb-8 rounded-xl bg-gray-50 p-6">
			<div class="">
				<p class="text-xl font-semibold">🎉 Limited-Time Offer! 🎉</p>
				<p class="text-base font-normal">
					Early Adopters Special: Enjoy a seamless, ad-free experience. Now at an exclusive early
					bird discount!
				</p>
				<p class="text-base font-normal">Act now! Offer available for a limited period only.</p>
			</div>

			<!-- Benefits Section -->
			<div class="mt-2">
				<h3 class="mb-1 text-2xl font-semibold">Benefits</h3>
				<ul class="space-y-0">
					<li class="flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">No more interruptions</span>
					</li>
					<li class="flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Ad-free gameplay</span>
					</li>
					<li class="flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Faster loading times</span>
					</li>
					<li class="flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">One-time purchase</span>
					</li>
					<li class="flex items-center">
						<span class="mr-2 text-green-500">✓</span>
						<span class="text-lg">Supports future development</span>
					</li>
				</ul>
			</div>
		</div>
	</div>

	<!-- Purchase Button -->
	<div class="p-4">
		{#if $adsRemoved}
			<button class="w-full rounded-xl bg-green-700 py-4 text-white">
				<span class="text-xl font-semibold">✓ Ads Removed!</span>
			</button>
		{:else}
			<button
				class="relative w-full rounded-xl bg-blue-700 py-4 text-white active:bg-blue-800"
				on:click={buyRemoveAds}
			>
				<span class="absolute left-4 rounded-md bg-red-700 px-2 py-1 text-sm text-white"
					>60% Off</span
				>
				<span class="text-xl font-semibold">{price}</span>
			</button>
			<button class="w-full py-4 text-center text-blue-700 active:text-blue-800" on:click={restore}>
				Restore Remove Ads
			</button>
		{/if}
	</div>
</div>

<style>
	/* Add any additional custom styles here if needed */
</style>
