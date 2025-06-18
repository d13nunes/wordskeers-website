<script lang="ts">
	import Modal from '../Modal.svelte';
	import GameModeIconTitle from '../GameModeIconTitle.svelte';

	import LevelsGiftIcon from './LevelsGiftIcon.svelte';
	import { slide } from 'svelte/transition';

	interface Props {
		onGiveReward?: () => void;
		onCoinAnimationCompleted?: () => void;
	}

	let { onGiveReward, onCoinAnimationCompleted } = $props();

	let isCoinCollectingAnimation = $state(false);

	function handlePlayClick() {
		isCoinCollectingAnimation = true;
	}
</script>

<Modal>
	<div class="flex w-full max-w-md flex-col items-center pt-2">
		<GameModeIconTitle title="WELCOME!" subtitle="Ready to Play?" />
		<button class="mt-8" onclick={handlePlayClick}>
			<LevelsGiftIcon
				isAnimating={true}
				animateCoin={isCoinCollectingAnimation}
				{onGiveReward}
				{onCoinAnimationCompleted}
			/>
		</button>
		<!-- Welcome Message -->
		<div class="max-w-2xs px-1 py-6 pb-8">
			<p class="text-center text-lg font-medium text-gray-900">
				Every great journey begins with the first step. Here are <b>350 coins</b> to help you on
				your word seeking adventure.
				<!-- As a small thank you for joining us, please accept this welcome gift.<br /> -->
			</p>
		</div>

		<!-- Play Button -->
		{#if !isCoinCollectingAnimation}
			<div
				out:slide={{ duration: 300, axis: 'y' }}
				class="flex justify-center"
				id="claim-coins-button"
			>
				<button
					onclick={handlePlayClick}
					disabled={isCoinCollectingAnimation}
					class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white"
				>
					Claim 350 Coins
				</button>
			</div>
		{/if}
	</div>
</Modal>
