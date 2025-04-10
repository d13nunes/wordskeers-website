<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindWordIcon from './Icons/FindWordIcon.svelte';
	interface Props {
		onclick: () => void;
		price: string;
	}

	let { onclick, price }: Props = $props();
</script>

<PowerUpButton
	color="bg-cyan-50"
	title="Find Word"
	titleColor="text-cyan-700"
	priceColor="text-cyan-600"
	{onclick}
	{price}
>
	{#snippet icon()}
		<FindWordIcon color="#007595" />
	{/snippet}
</PowerUpButton>
