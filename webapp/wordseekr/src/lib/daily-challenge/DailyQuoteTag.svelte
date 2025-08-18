<script lang="ts">
	import BaseTag from '$lib/components/BaseTag.svelte';
	import dailyQuoteIcon from '$lib/assets/quote-icon.png';
	import { onMount } from 'svelte';
	import { animateQuoteTag, expandQuoteTag } from '$lib/tag-store';
	import { isDarkMode } from '$lib/utils/darkmode';
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
	<div class="pt-[2px] lg:pt-[3px]">
		<img src={dailyQuoteIcon} alt="Daily Quote" style="filter: {$isDarkMode ? 'invert(1)' : 'none'};" />
	</div>
</BaseTag>
