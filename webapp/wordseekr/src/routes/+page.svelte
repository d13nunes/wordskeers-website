<script lang="ts">
	import ClassicGameModeSelection from './ClassicGameModeSelection.svelte';

	import { Difficulty } from '$lib/game/difficulty';
	import LevelsGameModeSelection from './LevelsGameModeSelection.svelte';

	let isClassicGameMode = $state(false);
</script>

<div class="fixed inset-0 z-50 bg-slate-50">
	{#if isClassicGameMode}
		<!-- Classic Game Mode -->
		<ClassicGameModeSelection />
	{:else}
		<LevelsGameModeSelection />
	{/if}
</div>
