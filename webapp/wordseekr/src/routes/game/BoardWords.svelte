<script lang="ts">
	import { getFormatedTime, toTitleCase } from '$lib/utils/string-utils';
	import ClockIcon from '$lib/components/Icons/ClockIcon.svelte';
	import type { Snippet } from 'svelte';

	interface Props {
		showClock: boolean;
		elapsedTime: number;
		title: string;
		onClockClick: (isVisible: boolean) => void;
		children: Snippet;
	}

	const { showClock, elapsedTime, title, onClockClick, children }: Props = $props();
	let isClockVisible = $state(showClock);
	function onClockClick_() {
		isClockVisible = !isClockVisible;
		onClockClick(isClockVisible);
	}
</script>

<div class="flex flex-col items-center justify-center gap-2 py-2">
	<button type="button" class="flex w-full items-end justify-between" onclick={onClockClick_}>
		<span class="text-start text-2xl font-bold text-gray-700">{toTitleCase(title)}</span>
		<div class="flex h-7 min-w-18 items-center justify-end gap-1">
			{#if isClockVisible}
				<span class="font-mono text-gray-700">{getFormatedTime(elapsedTime)}</span>
			{/if}
			<div class="h-4 w-4">
				<ClockIcon color="#37385F" />
			</div>
		</div>
	</button>
	{@render children()}
</div>
