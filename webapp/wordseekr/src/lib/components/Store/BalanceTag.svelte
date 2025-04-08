<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import PlusCircleIcon from '$lib/components/Icons/PlusCircleIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import { isIAPAvailable } from '$lib/economy/iapStore';
	import { onMount } from 'svelte';

	let balance = $state(0);
	let isActive = $state(false);
	let { onclick } = $props();

	walletStore.coins((newBalance) => (balance = newBalance));

	onMount(async () => {
		isActive = await isIAPAvailable();
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
	<span class="text-black-500 text-sm font-medium lg:text-lg">{balance}</span>

	{#if isActive}
		<div class="h-4 w-4 lg:h-6 lg:w-6">
			<PlusCircleIcon fillColor="#00c951" />
		</div>
	{/if}
</button>
