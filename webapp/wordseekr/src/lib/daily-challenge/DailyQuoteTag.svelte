<script lang="ts">
	import BaseTag from '$lib/components/BaseTag.svelte';
	import DailyQuoteIcon from './DailyQuoteIcon.svelte';

	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();
</script>

<BaseTag {onclick}>
	<div class="mt-0 flex h-4 max-h-4 w-4 max-w-4 flex-row gap-1 lg:h-8 lg:w-8">
		<DailyQuoteIcon />
	</div>
	<span class="text-black-500 text-sm font-medium lg:text-lg">Quotes</span>
</BaseTag>
