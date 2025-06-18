<script lang="ts">
	import LevelsEndGameModal from '$lib/components/Levels/LevelsEndGameModal.svelte';

	let showModal = $state(true);
	let previousProgressValue = $state(0);
	let currentProgressValue = $state(100);
	let levelNumber = $state(1);
	let levelName = $state('Level 1');
	let stageName = $state('Stage 1');
</script>

<div>
	<h1>End Level Modal</h1>

	<div class="flex flex-col gap-8">
		<div class="flex flex-col border-2 border-black">
			<label for="previousProgressValue">Previous Progress Value</label>
			<input type="number" bind:value={previousProgressValue} />
		</div>
		<div class="flex flex-col border-2 border-black">
			<label for="currentProgressValue">Current Progress Value</label>
			<input type="number" bind:value={currentProgressValue} />
		</div>
		<div class="flex flex-col border-2 border-black">
			<label for="levelNumber">Level Number</label>
			<input type="number" bind:value={levelNumber} />
		</div>
		<div class="flex flex-col border-2 border-black">
			<label for="levelName">Level Name</label>
			<input type="text" bind:value={levelName} />
		</div>
		<div class="flex flex-col border-2 border-black">
			<label for="stageName">Stage Name</label>
			<input type="text" bind:value={stageName} />
		</div>

		<button
			onclick={() => {
				showModal = true;
			}}
		>
			<div class="flex h-12 w-xl flex-row items-center justify-center bg-amber-200">show modal</div>
		</button>
	</div>
	{#if showModal}
		<LevelsEndGameModal
			onClose={() => {
				showModal = false;
			}}
			{previousProgressValue}
			{currentProgressValue}
			{levelNumber}
			{levelName}
			{stageName}
			navigateToNextLevel={() => {
				// showModal = false;
			}}
		/>
	{/if}
</div>
