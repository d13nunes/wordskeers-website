<script lang="ts">
	import Tag from '$lib/components/Tag.svelte';
	import { getFormatedTime, toTitleCase } from '$lib/utils/string-utils';
	import ClockIcon from '$lib/components/Icons/ClockIcon.svelte';
	import { flip } from 'svelte/animate';
	import type { Word } from '$lib/components/Game/game';

	interface Props {
		words: Word[];
		showClock: boolean;
		elapsedTime: number;
		title: string;
		onClockClick: (isVisible: boolean) => void;
	}

	const { words, showClock, elapsedTime, title, onClockClick }: Props = $props();
	let isClockVisible = $state(showClock);
	function onClockClick_() {
		isClockVisible = !isClockVisible;
		onClockClick(isClockVisible);
	}
</script>

<div class="flex flex-col items-center justify-center gap-2 py-2">
	<button type="button" class="flex w-full items-end justify-between" onclick={onClockClick_}>
		<span class=" text-2xl font-bold text-gray-700">{title}</span>
		<div class="flex h-7 min-w-18 items-center justify-end gap-1">
			{#if isClockVisible}
				<span class="font-mono text-gray-700">{getFormatedTime(elapsedTime)}</span>
			{/if}
			<div class="h-4 w-4">
				<ClockIcon color="#37385F" />
			</div>
		</div>
	</button>
	<div class="flex w-full flex-row flex-wrap items-start justify-start gap-2">
		{#each words as word (word.word)}
			<div animate:flip={{ duration: 450 }}>
				<Tag
					tag={toTitleCase(word.word)}
					isDiscovered={word.isDiscovered}
					bgColor={word.color}
					textColor={word.textColor}
				/>
			</div>
		{/each}
	</div>
</div>
