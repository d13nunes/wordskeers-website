<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import RotateIcon from './Icons/RotateIcon.svelte';
	import { isDarkMode } from '$lib/utils/darkmode';
	
	interface Props {
		onclick: () => void;
		price: string;
		disabled?: boolean;
		id: string;
	}

	export let onclick: Props['onclick'];
	export let price: Props['price'];
	export let disabled: Props['disabled'] = false;
	export let id: Props['id'];
</script>

<PowerUpButton
	color={$isDarkMode ? 'bg-emerald-800' : 'bg-emerald-50'}
	{price}
	title="Rotate"
	titleColor={$isDarkMode ? 'text-emerald-100' : 'text-emerald-700'}
	priceColor={$isDarkMode ? 'text-emerald-200' : 'text-emerald-600'}
	{onclick}
	{disabled}
>
	{#snippet icon()}
		<RotateIcon {id} color={$isDarkMode ? 'oklch(69.6% 0.17 162.48)' : '#007a55'} />
	{/snippet}
</PowerUpButton>
