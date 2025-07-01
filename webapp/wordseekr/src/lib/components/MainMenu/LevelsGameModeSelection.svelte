<script lang="ts">
	import GameModeSelection from './GameModeSelection.svelte';
	import LevelsProgressBar from '$lib/components/Levels/LevelsProgressBar.svelte';
	import { onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { levelsManager } from '$lib/levels/levels';
	import type { Level } from '$lib/database/types';
	import LevelsGiftIcon from '$lib/components/Levels/LevelsGiftIcon.svelte';
	import { gotoLevel } from '../../../routes/utils/naviation';

	let { isNewUser }: { isNewUser: boolean } = $props();

	let isSmallScreen = $state(getIsSmallScreen());
	let level: Level | undefined = $state(undefined);
	let levelName: string = $state(levelsManager.level?.name ?? '');
	let levelNumber: number | undefined = $state(levelsManager.level?.orderIndex ?? undefined);
	let previousProgressPercentage = $state(0);
	let currentProgressPercentage = $state(0);
	let nextGridId = $state(0);
	let isGiftAnimating = $state(true);

	onMount(async () => {
		levelsManager.init().then(() => {
			levelsManager.progress.subscribe((progress) => {
				currentProgressPercentage = progress * 100;
			});
			levelsManager.currentLevel.subscribe(async (_level) => {
				level = _level;
				levelName = level?.name ?? '';
				levelNumber = level?.orderIndex ?? 0;
				nextGridId = await levelsManager.getNextGridId();
			});
			if (levelsManager.__currentLevel) {
				level = levelsManager.__currentLevel;
				levelName = level?.name ?? '';
				levelNumber = level?.orderIndex ?? 0;
			}
		});
		if (isNewUser) {
			onPlayClick();
		}
	});

	async function onPlayClick() {
		console.log('onPlayClick', nextGridId, levelNumber);
		gotoLevel(nextGridId, levelNumber ?? -1);
	}
</script>

<!-- Levels Game Mode -->
<GameModeSelection
	title={levelNumber ? `Level ${levelNumber}` : 'Levels'}
	subtitle={levelName}
	{onPlayClick}
>
	<button
		class="mt-6 mb-2 {isSmallScreen
			? 'landscape:mt-0 landscape:mb-0 lg:landscape:mt-6 lg:landscape:mb-2'
			: ''}"
		onclick={onPlayClick}
	>
		<LevelsGiftIcon isAnimating={isGiftAnimating} />
	</button>
	<div class="flex flex-col items-center pb-2 {isSmallScreen ? 'landscape:pb-0' : ''}">
		<span class="text-base font-normal text-gray-500">Complete levels and win prizes</span>
	</div>

	<LevelsProgressBar
		class="w-full px-4 pb-0.5 {isSmallScreen ? 'landscape:pb-0' : ''}"
		startAnimation={true}
		currentProgressValue={currentProgressPercentage}
		previousProgressValue={previousProgressPercentage}
	/>
</GameModeSelection>
