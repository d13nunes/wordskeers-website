<script lang="ts">
	import BaseTag from '../BaseTag.svelte';
	import classicModeIcon from '$lib/assets/magnifier-glass.webp';
	import { isDarkMode } from '$lib/utils/darkmode';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();

	let isExpanded = $state(true);
	let isAnimating = $state(false);
</script>

<BaseTag {onclick} title="Classic" {isExpanded} {isAnimating}>
	<img src={classicModeIcon} alt="Classic Mode" style="filter: {$isDarkMode ? 'invert(1)' : 'none'};" />
</BaseTag>
