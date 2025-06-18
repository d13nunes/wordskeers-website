<script lang="ts">
	import { onMount } from 'svelte';
	import { gotoMainMenu } from './utils/naviation';
	import magnifyingGlass from '$lib/assets/magnifier-glass.webp';
	import { fade } from 'svelte/transition';
	import { goto } from '$app/navigation';
	import { levelsManager } from '$lib/levels/levels';
	import { gameCounter } from '$lib/storage/local-storage';

	let isVisible = $state(false);

	onMount(async () => {
		const isNewUser = (await gameCounter.getCount()) === 0;
		setTimeout(() => {
			if (isNewUser) {
				playFirstLevel();
			} else {
				gotoMainMenu();
			}
		}, 200);
	});

	async function playFirstLevel() {
		await levelsManager.init();
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`);
	}
</script>

{#if isVisible}
	<div
		in:fade
		out:fade
		class="fixed inset-0 mb-20 flex flex-col items-center justify-center gap-10"
	>
		<img
			src={magnifyingGlass}
			alt="Logo"
			class="mb-1 aspect-square h-42 w-42 object-contain lg:h-32 lg:w-32"
		/>

		<span class="text-5xl font-bold drop-shadow-md lg:text-6xl">WORD SEEKER</span>
	</div>
{/if}
