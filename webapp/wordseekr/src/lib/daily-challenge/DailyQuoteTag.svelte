<script lang="ts">
	import BaseTag from '$lib/components/BaseTag.svelte';
	import DailyQuoteIcon from './DailyQuoteIcon.svelte';
	import { onMount } from 'svelte';
	import { animateQuoteTag, expandQuoteTag } from '$lib/tag-store';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();
	let isExpanded = $state(false);
	let isAnimating = $state(false);

	onMount(() => {
		expandQuoteTag.subscribe((value: boolean) => {
			isExpanded = value;
		});
		animateQuoteTag.subscribe((value: boolean) => {
			isAnimating = value;
		});
	});
</script>

<BaseTag {onclick} {isExpanded} {isAnimating} title="Quotes">
	<DailyQuoteIcon />
</BaseTag>
