<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindWordIcon from './Icons/FindWordIcon.svelte';
	import { isDarkMode } from '$lib/utils/darkmode';
	
	interface Props {
		onclick: () => void;
		id: string;
		price: string;
		disabled?: boolean;
	}

	let { onclick, price, disabled = false, id }: Props = $props();
</script>

<PowerUpButton
	color={$isDarkMode ? 'bg-cyan-800' : 'bg-cyan-50'}
	title="Find Word"
	titleColor={$isDarkMode ? 'text-cyan-100' : 'text-cyan-700'} 
	priceColor={$isDarkMode ? 'text-cyan-200' : 'text-cyan-600'}
	{onclick}
	{price}
	{disabled}
>
	{#snippet icon()}
		<FindWordIcon {id} color={$isDarkMode ? 'oklch(71.5% 0.143 215.221)' : '#0E7490'} />
	{/snippet}
</PowerUpButton>
