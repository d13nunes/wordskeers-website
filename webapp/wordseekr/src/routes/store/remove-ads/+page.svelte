<script lang="ts">
	import { goto } from '$app/navigation';
	export let buyRemoveAds: () => void = () => {
		console.log('buy remove ads');
	};
	export let restore: () => void = () => {
		console.log('restore remove ads');
	};
</script>

<!-- Header -->

<div class="relative flex h-svh w-svw flex-col bg-white">
	<!-- Main Content -->
	<button
		class="text-md absolute top-4 left-4 font-normal text-blue-500"
		onclick={() => goto('/store')}
	>
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
		<button
			class="relative w-full rounded-xl bg-blue-700 py-4 text-white active:bg-blue-800"
			onclick={buyRemoveAds}
		>
			<span class="absolute left-4 rounded-md bg-red-700 px-2 py-1 text-sm text-white">60% Off</span
			>
			<span class="text-xl font-semibold">3,99 €</span>
		</button>
		<button class="w-full py-4 text-center text-blue-700 active:text-blue-800" onclick={restore}>
			Restore Remove Ads
		</button>
	</div>
</div>

<style>
	/* Add any additional custom styles here if needed */
</style>
