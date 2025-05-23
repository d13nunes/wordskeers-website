<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import RotateIcon from './Icons/RotateIcon.svelte';

	interface Props {
		onclick: () => void;
		price: string;
		disabled?: boolean;
		id: string;
	}

	let { onclick, price, disabled = false, id }: Props = $props();
</script>

<PowerUpButton
	color="bg-emerald-50"
	{price}
	title="Rotate"
	titleColor="text-emerald-700"
	priceColor="text-emerald-600"
	{onclick}
	{disabled}
>
	{#snippet icon()}
		<RotateIcon {id} color="#007a55" />
	{/snippet}
</PowerUpButton>
