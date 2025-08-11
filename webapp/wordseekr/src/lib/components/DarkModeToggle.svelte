<script>
	import DarkModeIcon from '$lib/components/Icons/DarkModeIcon.svelte';
	import LightModeIcon from '$lib/components/Icons/LightModeIcon.svelte';
	import { isDarkMode, toggleMode } from '$lib/utils/darkmode';
	import BaseTag from './BaseTag.svelte';

	function onclick() {
		console.log('toggleMode');
		toggleMode();
	}
	let isExpanded = $state(false);
	let isAnimating = $state(false);
</script>

<BaseTag {onclick} {isExpanded} {isAnimating} title="Dark Mode">
	{#if $isDarkMode}
		<LightModeIcon />
	{:else}
		<DarkModeIcon />
	{/if}
</BaseTag>
