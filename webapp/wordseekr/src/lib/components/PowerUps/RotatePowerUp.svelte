<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import RotateIcon from './Icons/RotateIcon.svelte';

	interface Props {
		onclick: () => void;
		price: string;
	}

	let { onclick, price }: Props = $props();
</script>

<PowerUpButton
	color="bg-emerald-50"
	{price}
	title="Rotate"
	titleColor="text-emerald-700"
	priceColor="text-emerald-600"
	{onclick}
>
	{#snippet icon()}
		<RotateIcon color="#007a55" />
	{/snippet}
</PowerUpButton>
