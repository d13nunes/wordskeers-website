<script lang="ts">
	import Tag from '$lib/components/Tag.svelte';
	import { toTitleCase } from '$lib/utils/string-utils';
	import type { Word } from '$lib/components/Game/game';
	import BoardWords from './BoardWords.svelte';
	interface Props {
		words: Word[];
		showClock: boolean;
		elapsedTime: number;
		title: string;
		onClockClick: (isVisible: boolean) => void;
	}

	const { words, showClock, elapsedTime, title, onClockClick }: Props = $props();
</script>

<BoardWords {showClock} {elapsedTime} {title} {onClockClick}>
	<div class="flex w-full flex-row flex-wrap items-start justify-start gap-2">
		{#each words as word (word.word)}
			<div id={word.word.toLowerCase()}>
				<Tag
					tag={toTitleCase(word.word)}
					isDiscovered={word.isDiscovered}
					bgColor={word.color}
					textColor={word.textColor}
				/>
			</div>
		{/each}
	</div>
</BoardWords>
