<script lang="ts">
	import GameEndedModal from '$lib/components/Game/GameEndedModal.svelte';
	interface Props {
		elapsedTime: string;
		accumulatedCoins: number;
		onRewardAnimationCompleted: () => void;
		onRewardGiven: () => void;
		collectReward: () => Promise<void>;
		doubleReward: () => Promise<void>;
		isRewardAdReady: boolean;
	}
	const {
		elapsedTime,
		accumulatedCoins,
		collectReward,
		doubleReward,
		isRewardAdReady,
		onRewardAnimationCompleted,
		onRewardGiven
	}: Props = $props();
</script>

<GameEndedModal
	title="Classic"
	subtitle="Game Mode"
	continueButtonText="Collect"
	doubleButtonText="Double"
	onClickContinue={async () => await collectReward()}
	onClickDouble={async () => await doubleReward()}
	showDoubleButton={isRewardAdReady}
	{onRewardAnimationCompleted}
	{onRewardGiven}
>
	<p class="w-2xs text-center text-lg leading-relaxed text-gray-700">
		You found all the words in {elapsedTime}.<br />You've earned <b>{accumulatedCoins}</b> coins!
	</p>
</GameEndedModal>
