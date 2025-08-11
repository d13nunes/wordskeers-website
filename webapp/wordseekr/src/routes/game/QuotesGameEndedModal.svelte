<script lang="ts">
	import GameEndedModal from '$lib/components/Game/GameEndedModal.svelte';
	import QuoteIcon from '$lib/assets/Quote.png';
	import type { DailyChallenge } from '$lib/daily-challenge/models';
	import { normalizeQuoteText } from '$lib/utils/utils';

	interface Props {
		accumulatedCoins: number;
		quoteChallenge: DailyChallenge;
		onRewardAnimationCompleted: () => void;
		onRewardGiven: () => void;
		collectReward: () => Promise<void>;
		doubleReward: () => Promise<void>;
		isRewardAdReady: boolean;
	}
	const {
		quoteChallenge,
		accumulatedCoins,
		collectReward,
		doubleReward,
		isRewardAdReady,
		onRewardAnimationCompleted,
		onRewardGiven
	}: Props = $props();

	let normalizedQuote = $derived(normalizeQuoteText(quoteChallenge.quotes));
</script>

<GameEndedModal
	title="Quotes"
	subtitle="Daily Challenge"
	continueButtonText="Collect"
	doubleButtonText="Double"
	onClickContinue={async () => await collectReward()}
	onClickDouble={async () => await doubleReward()}
	showDoubleButton={isRewardAdReady}
	{onRewardAnimationCompleted}
	{onRewardGiven}
>
	<div class="my-2 flex flex-col gap-1">
		<div>
			<div class="rounded-md  bg-background-secondary p-4 dark:bg-gray-800">
				<span class="text-center text-lg font-medium text-gray-700 dark:text-gray-300">
					<b>{quoteChallenge.title}</b>
				</span>
				<div class="text-sm text-gray-700 dark:text-gray-300">
					{#if normalizedQuote}
						{#each normalizedQuote as quote}
							{#if quote.isHidden}
								<span class="font-semibold">{quote.text}</span>
							{:else}
								<span class="font-light">{quote.text}</span>
							{/if}
							<span class=""> </span>
						{/each}
					{/if}
				</div>
			</div>
		</div>
	</div>
</GameEndedModal>
