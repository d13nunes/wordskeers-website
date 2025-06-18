<script lang="ts">
	import GameEndedModal from '$lib/components/Game/GameEndedModal.svelte';
	import magnifyingGlass from '$lib/assets/magnifier-glass.webp';
	import Modal from '$lib/components/Modal.svelte';
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
	icon={magnifyingGlass}
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
	<p class="text-center text-lg text-gray-700" style="white-space: pre-line;">
		You found all the words in {elapsedTime}<br />You've earned <b> {accumulatedCoins}</b> coins!
	</p>
</GameEndedModal>
