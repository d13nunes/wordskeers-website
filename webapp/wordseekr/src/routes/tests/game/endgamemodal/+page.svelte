<script lang="ts">
	import ClassicGameEndedModal from '../../../game/ClassicGameEndedModal.svelte';
	import QuotesGameEndedModal from '../../../game/QuotesGameEndedModal.svelte';
	let isVisibleClassic = $state(false);
	let isVisibleQuotes = $state(false);

	const quoteChallenge = JSON.parse(
		'{"id":"18","title":"Joseph Campbell","rows":6,"columns":6,"date":"2025-06-19T00:00:00.000Z","quotes":[{"text":"YOUR","isHidden":false,"isDiscovered":false},{"text":"SACRED","isHidden":true,"isDiscovered":false},{"text":"SPACE","isHidden":true,"isDiscovered":false},{"text":"IS","isHidden":false,"isDiscovered":false},{"text":"WHERE","isHidden":true,"isDiscovered":false},{"text":"YOU","isHidden":false,"isDiscovered":false},{"text":"CAN","isHidden":false,"isDiscovered":false},{"text":"FIND","isHidden":true,"isDiscovered":false},{"text":"YOURSELF","isHidden":false,"isDiscovered":false},{"text":"AGAIN","isHidden":false,"isDiscovered":false},{"text":"AND","isHidden":false,"isDiscovered":false},{"text":"AGAIN","isHidden":true,"isDiscovered":false},{"text":".","isHidden":false,"isDiscovered":false}],"words":[{"word":"AGAIN","initialPosition":{"row":5,"col":1},"direction":{"name":5,"dx":1,"dy":-1,"angle":-45}},{"word":"SACRED","initialPosition":{"row":5,"col":0},"direction":{"name":5,"dx":1,"dy":-1,"angle":-45}},{"word":"FIND","initialPosition":{"row":5,"col":2},"direction":{"name":3,"dx":1,"dy":0,"angle":0}},{"word":"SPACE","initialPosition":{"row":1,"col":0},"direction":{"name":3,"dx":1,"dy":0,"angle":0}},{"word":"WHERE","initialPosition":{"row":0,"col":0},"direction":{"name":3,"dx":1,"dy":0,"angle":0}}]}'
	);
</script>

<div class="fixed inset-0 flex flex-col items-center justify-center gap-8">
	<div class="text-2xl font-bold">End Game Modals</div>
	<button
		class="rounded-md bg-blue-500 px-4 py-2 text-white"
		onclick={() => {
			isVisibleClassic = true;
			isVisibleQuotes = false;
		}}>Show Modal Classic</button
	>
	<button
		class="rounded-md bg-blue-500 px-4 py-2 text-white"
		onclick={() => {
			isVisibleQuotes = true;
			isVisibleClassic = false;
		}}>Show Modal Quotes</button
	>

	{#if isVisibleClassic}
		<ClassicGameEndedModal
			elapsedTime="02m 00s"
			accumulatedCoins={100}
			collectReward={async () => {}}
			doubleReward={async () => {}}
			isRewardAdReady={true}
			onRewardAnimationCompleted={() => {
				isVisibleClassic = false;
			}}
			onRewardGiven={() => {}}
		/>
	{/if}

	{#if isVisibleQuotes}
		<QuotesGameEndedModal
			{quoteChallenge}
			accumulatedCoins={100}
			collectReward={async () => {}}
			doubleReward={async () => {}}
			isRewardAdReady={true}
			onRewardAnimationCompleted={() => {
				isVisibleQuotes = false;
			}}
			onRewardGiven={() => {}}
		/>
	{/if}
</div>
