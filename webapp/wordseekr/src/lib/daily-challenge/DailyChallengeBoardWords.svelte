<script lang="ts">
	import type { Word } from '$lib/components/Game/game';
	import { fade } from 'svelte/transition';
	import BoardWords from '../../routes/game/BoardWords.svelte';
	import type { DailyChallenge } from './models';
	import { normalizeQuoteText } from '$lib/utils/utils';

	interface Props {
		dailyChallenge: DailyChallenge;
		words: Word[];
		showClock: boolean;
		elapsedTime: number;
		title: string;
		idPrefix: string;
		onClockClick: (isClockVisible: boolean) => void;
	}

	const { dailyChallenge, words, showClock, elapsedTime, title, idPrefix, onClockClick }: Props =
		$props();

	const normalizedQuoteSegments = $derived(normalizeQuoteText(dailyChallenge.quotes));
	$effect(() => {
		words
			.filter((word) => word.isDiscovered)
			.forEach((word) => {
				dailyChallenge.quotes.forEach((q) => {
					if (q.isHidden && q.text.toUpperCase() === word.word.toUpperCase()) {
						q.isDiscovered = true;
					}
				});
			});
	});
</script>

<BoardWords {showClock} hideClock={false} {elapsedTime} {title} {onClockClick}>
	<div class="flex flex-row flex-wrap gap-x-2 gap-y-0.5 font-mono text-sm text-gray-700">
		{#each normalizedQuoteSegments as quote, index}
			{#if index > 0}
				<!-- <span class="w-[7px]"></span> -->
			{/if}
			{#if quote.isHidden}
				<div id={idPrefix + quote.text.toLowerCase()} class="flex flex-row gap-[7px]">
					{#each quote.text.split('') as char, index}
						<span class="relative min-h-[18px] min-w-[0.4ch]">
							{#if quote.isDiscovered}
								<span in:fade={{ delay: 200 * index, duration: 200 }} class="absolute italic"
									>{char}</span
								>
							{/if}
							<span class="absolute">{'_'}</span>
						</span>
					{/each}
					<span class=""></span>
				</div>
			{:else}
				{#each quote.text.split(' ') as char}
					<span class="">{char}</span>
				{/each}
			{/if}
		{/each}
	</div>
</BoardWords>
