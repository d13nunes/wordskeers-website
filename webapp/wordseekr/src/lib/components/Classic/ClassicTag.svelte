<script lang="ts">
	import BaseTag from '../BaseTag.svelte';
	import classicModeIcon from '$lib/assets/magnifier-glass.webp';

	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();

	let isExpanded = $state(true);
	let isAnimating = $state(false);
</script>

<BaseTag {onclick} title="Classic" {isExpanded} {isAnimating}>
	<img src={classicModeIcon} alt="Classic Mode" />
</BaseTag>
