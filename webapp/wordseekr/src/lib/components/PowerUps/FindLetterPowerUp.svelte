<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindLetterIcon from './Icons/FindLetterIcon.svelte';

	export let onClick: () => void;
	export let price: string = '100';
</script>

<PowerUpButton
	color="bg-red-50"
	{price}
	title="Find Letter"
	titleColor="text-red-700"
	priceColor="text-red-600"
	{onClick}
>
	<FindLetterIcon color="#c10007" />
</PowerUpButton>
