<script lang="ts">
	import { levelsManager } from '$lib/levels/levels';
	import { onMount } from 'svelte';
	import BaseTag from '../BaseTag.svelte';
	import { goto } from '$app/navigation';
	import LevelsIcon from './LevelsIcon.svelte';

	let isInitialized = $state(false);

	let progress = $derived(levelsManager.progress);
	let currentLevelNumber = $derived(levelsManager.currentLevelNumber);

	onMount(() => {
		levelsManager.isInitialized.subscribe((value) => {
			isInitialized = value;
			console.log('isInitialized', isInitialized);
		});
		levelsManager.init();
	});

	async function onclick() {
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`);
	}
	let icon: HTMLDivElement | null = null;
</script>

<BaseTag {onclick}>
	{#if isInitialized}
		<div bind:this={icon} class="h-4 w-4">
			<LevelsIcon />
		</div>
		<span class="text-black-500 text-sm font-medium lg:text-base">Levels</span>
	{:else}
		<div class="flex items-center justify-center">
			<div
				class="h-4 w-4 animate-spin rounded-full border-2 border-gray-300 border-t-blue-500"
			></div>
		</div>
	{/if}
</BaseTag>
