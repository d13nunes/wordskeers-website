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

<div class="fixed inset-0 z-100 flex items-center justify-center bg-black/50"></div>
