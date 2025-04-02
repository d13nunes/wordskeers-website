<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindWordIcon from './Icons/FindWordIcon.svelte';
	export let onClick: () => void;
	export let price: string = '100';
</script>

<PowerUpButton
	color="bg-cyan-50"
	title="Find Word"
	titleColor="text-cyan-700"
	priceColor="text-cyan-600"
	{onClick}
>
	<FindWordIcon color="#007595" />
</PowerUpButton>
