<script lang="ts">
	import CoinsPileIcon from '../CoinsPileIcon.svelte';
	import PlusCircle from '../PlusCircle.svelte';

	export let balance: number;
	export let onClick: () => void;
</script>

<button on:click={onClick} class="card-button flex flex-row items-center justify-center gap-3">
	<div class="h-4 w-4">
		<CoinsPileIcon />
	</div>
	<span class="text-black-500 text-sm font-medium">{balance}</span>

	<div class="h-4 w-4">
		<PlusCircle fillColor="#00c951" />
	</div>
</button>
