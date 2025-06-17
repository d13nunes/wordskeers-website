<script lang="ts">
	import GameModeSelection from './GameModeSelection.svelte';
	import levelsIcon from '$lib/assets/levels-icon.png';
	import LevelsProgressBar from '$lib/components/Levels/LevelsProgressBar.svelte';
	import { onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { levelsManager } from '$lib/levels/levels';
	import type { Level } from '$lib/database/types';
	import { goto } from '$app/navigation';
	import LevelsGiftIcon from '$lib/components/Levels/LevelsGiftIcon.svelte';

	let isSmallScreen = $state(getIsSmallScreen());
	let level: Level | undefined = $state(undefined);
	let levelName: string = $state('');
	let levelNumber: number | undefined = $state(levelsManager.level?.orderIndex ?? undefined);
	let previousProgressPercentage = $state(0);
	let currentProgressPercentage = $state(0);

	let isGiftAnimating = $state(true);

	async function onPlayClick() {
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		// goto(`/tests/endlevelmodal`);
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`);
	}

	onMount(async () => {
		levelsManager.init().then(() => {
			levelsManager.progress.subscribe((progress) => {
				console.log('🙏 levelsManager progress', progress);

				currentProgressPercentage = progress * 100;
				console.log('🙏🙏🙏 progress', currentProgressPercentage, progress);
			});
			levelsManager.currentLevel.subscribe((_level) => {
				level = _level;
				levelName = _level?.name ?? '';
				levelNumber = _level?.orderIndex ?? 0;
				console.log('🙏🙏🙏 levelNumber', levelNumber);
			});
		});
	});

	$inspect('🙏🙏🙏!! 1', levelNumber);
</script>

<!-- Levels Game Mode -->
<GameModeSelection
	title={levelNumber ? `Level ${levelNumber}` : ''}
	subtitle={levelName}
	{onPlayClick}
>
	<button
		class="mt-6 mb-2 {isSmallScreen ? 'landscape:mt-0 landscape:mb-0' : ''}"
		onclick={onPlayClick}
	>
		<LevelsGiftIcon isAnimating={isGiftAnimating} />
	</button>
	<div class="flex flex-col items-center pb-2 {isSmallScreen ? 'landscape:pb-0' : ''}">
		<span class="text-base font-normal text-gray-500">Complete levels and win prizes</span>
	</div>

	<LevelsProgressBar
		class="w-full px-4 pb-4 {isSmallScreen ? 'landscape:pb-0' : ''}"
		startAnimation={true}
		currentProgressValue={currentProgressPercentage}
		previousProgressValue={previousProgressPercentage}
	/>
</GameModeSelection>
