<script lang="ts">
	import GameEndedModal from '$lib/components/Game/GameEndedModal.svelte';
	import QuoteIcon from '$lib/assets/Quote.png';
	import type { DailyChallenge } from '$lib/daily-challenge/models';

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
</script>

<GameEndedModal
	icon={QuoteIcon}
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
			<div class="rounded-md border border-gray-200 bg-gray-100 p-4">
				<span class="text-center text-lg font-medium text-gray-700">
					<b>{quoteChallenge.title}</b>
				</span>
				<div class="text-sm text-gray-700">
					{#if quoteChallenge.quotes}
						{#each quoteChallenge.quotes as quote}
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
