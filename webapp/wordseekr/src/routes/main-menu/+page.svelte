<script lang="ts">
	import { isGameModeSelectionClassic } from '$lib/tag-store';
	import { onMount } from 'svelte';
	import { levelsManager } from '$lib/levels/levels';
	import { gameCounter } from '$lib/storage/local-storage';
	import { goto } from '$app/navigation';
	import { fade } from 'svelte/transition';
	import LevelsGameModeSelection from '$lib/components/MainMenu/LevelsGameModeSelection.svelte';
	import ClassicGameModeSelection from '$lib/components/MainMenu/ClassicGameModeSelection.svelte';

	let isClassicGameMode = $state(false);
	let isVisible = $state(false);
	onMount(async () => {
		isVisible = true;
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

		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`);
	}
</script>

{#if isVisible}
	<div in:fade class="fixed inset-0 z-50 bg-slate-50">
		{#if isClassicGameMode}
			<!-- Classic Game Mode -->
			<ClassicGameModeSelection />
		{:else}
			<LevelsGameModeSelection {onPlayClick} />
		{/if}
	</div>
{/if}
