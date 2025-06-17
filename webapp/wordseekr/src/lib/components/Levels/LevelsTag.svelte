<script lang="ts">
	import { levelsManager } from '$lib/levels/levels';
	import { onMount } from 'svelte';
	import BaseTag from '../BaseTag.svelte';
	import LevelsIcon from './LevelsIcon.svelte';

	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();

	let isInitialized = $state(false);
	let isExpanded = $state(true);
	let isAnimating = $state(false);
	onMount(() => {
		levelsManager.isInitialized.subscribe((value) => {
			isInitialized = value;
			isExpanded = isInitialized;
		});
		levelsManager.init();
	});
</script>

<BaseTag {onclick} title="Levels" {isExpanded} {isAnimating}>
	<LevelsIcon />
</BaseTag>
