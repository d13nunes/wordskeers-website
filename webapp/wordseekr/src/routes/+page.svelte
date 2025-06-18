<script lang="ts">
	import ClassicGameModeSelection from './ClassicGameModeSelection.svelte';
	import LevelsGameModeSelection from './LevelsGameModeSelection.svelte';
	import { isGameModeSelectionClassic, setGameModeSelectionClassic } from '$lib/tag-store';
	import { onMount } from 'svelte';
	import { levelsManager } from '$lib/levels/levels';
	import { gameCounter } from '$lib/storage/local-storage';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';

	const startWithClassic = page.url.searchParams.get('classic') === 'true';

	let isClassicGameMode = $state(false);
	console.log('isClassicGameMode', startWithClassic, page.url.searchParams);

	onMount(async () => {
		isGameModeSelectionClassic.subscribe((value) => {
			isClassicGameMode = value;
		});
		const isNewUser = (await gameCounter.getCount()) === 0;
		if (isNewUser) {
			onPlayClick();
		}
	});
	async function onPlayClick() {
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		setGameModeSelectionClassic(true);
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`);
	}
</script>

<div class="fixed inset-0 z-50 bg-slate-50">
	{#if isClassicGameMode}
		<!-- Classic Game Mode -->
		<ClassicGameModeSelection />
	{:else}
		<LevelsGameModeSelection {onPlayClick} />
	{/if}
</div>
