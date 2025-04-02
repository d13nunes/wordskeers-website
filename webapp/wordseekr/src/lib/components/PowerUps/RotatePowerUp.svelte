<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import RotateIcon from './Icons/RotateIcon.svelte';

	export let onClick: () => void;
	export let price: string = '100';
</script>

<PowerUpButton
	color="bg-emerald-50"
	{price}
	title="Rotate"
	titleColor="text-emerald-700"
	priceColor="text-emerald-600"
	{onClick}
>
	<RotateIcon color="#007a55" />
</PowerUpButton>
