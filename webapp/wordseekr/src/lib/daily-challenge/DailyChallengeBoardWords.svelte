<script lang="ts">
	import type { Word } from '$lib/components/Game/game';
	import { fade } from 'svelte/transition';
	import BoardWords from '../../routes/game/BoardWords.svelte';
	import type { DailyChallenge } from './models';

	interface Props {
		dailyChallenge: DailyChallenge;
		words: Word[];
		showClock: boolean;
		elapsedTime: number;
		title: string;
		onClockClick: (isClockVisible: boolean) => void;
	}

	const { dailyChallenge, words, showClock, elapsedTime, title, onClockClick }: Props = $props();

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

<BoardWords {showClock} {elapsedTime} {title} {onClockClick}>
	<div class="flex flex-row flex-wrap gap-2 font-mono text-gray-700">
		{#each dailyChallenge.quotes as quote}
			{#if quote.isHidden}
				<div id={quote.text.toLowerCase()} class="flex flex-row gap-[7px] pe-1.5">
					{#each quote.text.split('') as char, index}
						<span class="relative min-w-[0.5ch]">
							{#if quote.isDiscovered}
								<span
									in:fade={{ delay: 200 * index, duration: 200 }}
									class="absolute ps-[1px] italic"
								>
									{char}
								</span>
							{/if}
							<span class="absolute">{'_'}</span>
						</span>
					{/each}
				</div>
			{:else}
				{#each quote.text.split(' ') as char}
					<span class="">{char}</span>
				{/each}
			{/if}
		{/each}
	</div>
</BoardWords>
