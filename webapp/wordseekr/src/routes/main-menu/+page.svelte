<script lang="ts">
	import { isGameModeSelectionClassic } from '$lib/tag-store';
	import { onMount } from 'svelte';
	import { gameCounter } from '$lib/storage/local-storage';
	import { fade } from 'svelte/transition';
	import LevelsGameModeSelection from '$lib/components/MainMenu/LevelsGameModeSelection.svelte';
	import ClassicGameModeSelection from '$lib/components/MainMenu/ClassicGameModeSelection.svelte';

	let isClassicGameMode = $state(false);
	let isVisible = $state(false);
	let isNewUser = $state(false);
	onMount(async () => {
		isVisible = true;
		isGameModeSelectionClassic.subscribe((value) => {
			isClassicGameMode = value;
		});
		isNewUser = (await gameCounter.getCount()) === 0;
	});
</script>

{#if isVisible}
	<div in:fade class="flex h-full items-center justify-center">
		{#if isClassicGameMode}
			<!-- Classic Game Mode -->
			<ClassicGameModeSelection />
		{:else}
			<LevelsGameModeSelection {isNewUser} />
		{/if}
	</div>
{/if}
