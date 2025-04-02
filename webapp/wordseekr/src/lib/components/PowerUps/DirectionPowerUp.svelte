<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import DirectionIcon from './Icons/DirectionIcon.svelte';

	export let onClick: () => void;
	export let price: string = '100';
</script>

<PowerUpButton
	color="bg-orange-50"
	{price}
	title="Direction"
	titleColor="text-orange-700"
	priceColor="text-orange-600"
	{onClick}
>
	<DirectionIcon color="#bb4d00" />
</PowerUpButton>
