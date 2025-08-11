<script lang="ts">
	import PowerUpButton from './PowerUpButton.svelte';
	import FindLetterIcon from './Icons/FindLetterIcon.svelte';
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
	color={$isDarkMode ? 'bg-red-800' : 'bg-red-50'}
	{price}
	title="Find Letter"
	titleColor={$isDarkMode ? 'text-red-100' : 'text-red-700'}
	priceColor={$isDarkMode ? 'text-red-200' : 'text-red-600'}
	{onclick}
	{disabled}
>
	{#snippet icon()}
		<FindLetterIcon {id} color={$isDarkMode ? 'oklch(70.4% 0.191 22.216)' : '#B91C1C'} />
	{/snippet}
</PowerUpButton>
