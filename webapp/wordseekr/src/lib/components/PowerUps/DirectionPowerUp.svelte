<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import DirectionIcon from './Icons/DirectionIcon.svelte';

	interface Props {
		onclick: () => void;
		price: string;
	}

	let { onclick, price }: Props = $props();
</script>

<PowerUpButton
	color="bg-orange-50"
	{price}
	title="Direction"
	titleColor="text-orange-700"
	priceColor="text-orange-600"
	{onclick}
>
	{#snippet icon()}
		<DirectionIcon color="#bb4d00" />
	{/snippet}
</PowerUpButton>
