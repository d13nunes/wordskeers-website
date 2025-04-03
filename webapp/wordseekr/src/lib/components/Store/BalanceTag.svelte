<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import PlusCircleIcon from '$lib/components/Icons/PlusCircleIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';

	let balance = $state(0);
	walletStore.subscribe((newBalance) => (balance = newBalance));

	let { onclick } = $props();
	let isActive = true; // TODO: check if store store is active
</script>

<button
	class="card-button flex flex-row items-center justify-center gap-3"
	disabled={!isActive}
	{onclick}
>
	<div class="h-4 w-4">
		<CoinsPileIcon />
	</div>
	<span class="text-black-500 text-sm font-medium">{balance}</span>

	{#if isActive}
		<div class="h-4 w-4">
			<PlusCircleIcon fillColor="#00c951" />
		</div>
	{/if}
</button>
