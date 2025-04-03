<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import PlusCircleIcon from '$lib/components/Icons/PlusCircleIcon.svelte';

	export let balance: number;
	export let onClick: () => void;
	export let isActive: boolean = true;
</script>

<button
	on:click={onClick}
	class="card-button flex flex-row items-center justify-center gap-3"
	disabled={!isActive}
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
