<script lang="ts">
	import BaseTag from '../BaseTag.svelte';
	import classicModeIcon from '$lib/assets/magnifier-glass.webp';
	import { isDarkMode } from '$lib/utils/darkmode';
	import { onMount } from 'svelte';
	import { expandClassicTag } from '$lib/tag-store';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();

	let isExpanded = $state(false);
	let isAnimating = $state(false);

	onMount(() => {
		expandClassicTag.subscribe((value: boolean) => {
			isExpanded = value;
		});
	});
</script>

<BaseTag {onclick} title="Classic" {isExpanded} {isAnimating}>
	<img src={classicModeIcon} alt="Classic Mode" style="filter: {$isDarkMode ? 'invert(1)' : 'none'};" />
</BaseTag>
