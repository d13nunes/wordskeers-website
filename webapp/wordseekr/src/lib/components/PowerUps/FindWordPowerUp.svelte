<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindWordIcon from './Icons/FindWordIcon.svelte';
	interface Props {
		onclick: () => void;
		price: string;
		disabled?: boolean;
	}

	let { onclick, price, disabled = false }: Props = $props();
</script>

<PowerUpButton
	color="bg-cyan-50"
	title="Find Word"
	titleColor="text-cyan-700"
	priceColor="text-cyan-600"
	{onclick}
	{price}
	{disabled}
>
	{#snippet icon()}
		<FindWordIcon color="#0E7490" />
	{/snippet}
</PowerUpButton>
