<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import PlusCircleIcon from '$lib/components/Icons/PlusCircleIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import { isIAPAvailable } from '$lib/economy/iapStore';
	import { onMount } from 'svelte';
	import { animate, utils } from 'animejs';

	let balance = $state(0);
	let isActive = $state(false);
	let { onclick } = $props();
	let displayBalance = $state(0);

	walletStore.coins((newBalance) => {
		if (balance !== newBalance) {
			const oldDisplayBalance = displayBalance;
			balance = newBalance;
			let counter = { value: oldDisplayBalance };
			animate(counter, {
				value: newBalance,
				duration: 1000,
				ease: 'outExpo',
				modifier: utils.round(0),
				onUpdate: function () {
					displayBalance = counter.value;
				}
			});
		}
	});

	onMount(async () => {
		isActive = await isIAPAvailable();
		displayBalance = balance;
	});
</script>

<button
	class="card-button flex flex-row items-center justify-center gap-3 lg:gap-4"
	disabled={!isActive}
	{onclick}
>
	<div class="h-4 w-4 lg:h-6 lg:w-6">
		<CoinsPileIcon />
	</div>
	<span class="text-black-500 font-mono text-sm font-medium lg:text-lg">{displayBalance}</span>

	{#if isActive}
		<div class="h-4 w-4 lg:h-6 lg:w-6">
			<PlusCircleIcon fillColor="#00c951" />
		</div>
	{/if}
</button>
