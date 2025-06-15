<script lang="ts">
	import { goto } from '$app/navigation';
	import { levelsManager } from '$lib/levels/levels';
	import { onMount } from 'svelte';

	onMount(async () => {
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`, {
			replaceState: true
		});
	});
</script>
