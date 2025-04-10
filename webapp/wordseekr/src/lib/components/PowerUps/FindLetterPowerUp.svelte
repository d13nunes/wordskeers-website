<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindLetterIcon from './Icons/FindLetterIcon.svelte';

	interface Props {
		onclick: () => void;
		price: string;
	}

	let { onclick, price }: Props = $props();
</script>

<PowerUpButton
	color="bg-red-50"
	{price}
	title="Find Letter"
	titleColor="text-red-700"
	priceColor="text-red-600"
	{onclick}
>
	{#snippet icon()}
		<FindLetterIcon color="#c10007" />
	{/snippet}
</PowerUpButton>
