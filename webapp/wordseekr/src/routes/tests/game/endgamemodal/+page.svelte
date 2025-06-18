<script lang="ts">
	import GameEndedModal from '$lib/components/Game/GameEndedModal.svelte';
	import magnifyingGlass from '$lib/assets/magnifier-glass.webp';
	import ClassicGameEndedModal from '../../../game/ClassicGameEndedModal.svelte';
	let isVisible = $state(false);
</script>

<button onclick={() => (isVisible = true)}>Show Modal</button>

{#if isVisible}
	<ClassicGameEndedModal
		elapsedTime="00:00:00"
		accumulatedCoins={100}
		collectReward={async () => {}}
		doubleReward={async () => {}}
		isRewardAdReady={true}
		onRewardAnimationCompleted={() => {
			isVisible = false;
		}}
		onRewardGiven={() => {}}
	/>
{/if}
