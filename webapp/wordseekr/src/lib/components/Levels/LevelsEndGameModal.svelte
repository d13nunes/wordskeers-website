<script lang="ts">
	import Modal from '$lib/components/Modal.svelte';
	import GameModeIconTitle from '../GameModeIconTitle.svelte';
	import levelsIcons from '$lib/assets/levels.png';
	import { goto } from '$app/navigation';
	import { levelsManager } from '$lib/levels/levels';
	import { onMount } from 'svelte';
	import { animate, eases, utils } from 'animejs';
	import LevelsRewardIcon from '$lib/components/Levels/LevelsRewardIcon.svelte';

	interface Props {
		previousProgressValue: number;
		currentProgressValue: number;
		levelName: string;
		stageName: string;
		onClose: () => void;
	}

	const { previousProgressValue, currentProgressValue, levelName, stageName, onClose }: Props =
		$props();

	let icon = $state(levelsIcons);
	let iconId = $state('magnifierglassId');
	let levelNumber = $state(1);
	let title = $state('Levels');
	let progress = $state(previousProgressValue);
	let subtitle = $derived('Level ' + levelNumber + ' - ' + levelName);

	let rewardIcon: HTMLDivElement | null = null;

	async function onPlayClick() {
		const id = await levelsManager.getNextGridId();
		const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
		goto(`/game?id=${id}&difficulty=levels&level=${currentLevelNumber}`, {
			replaceState: true
		});
	}

	let rewardIconScaleInitial = 1 + previousProgressValue / 100;
	let rewardIconScaleMiddle =
		1 + (previousProgressValue + (currentProgressValue - previousProgressValue) / 2) / 100;
	let rewardIconScaleFinal = 1 + currentProgressValue / 100;
	console.log(rewardIconScaleInitial, rewardIconScaleMiddle, rewardIconScaleFinal);

	onMount(() => {
		let counter = { value: previousProgressValue };
		animate(counter, {
			value: currentProgressValue,
			delay: 500,
			duration: 1000,
			ease: 'inQuad',
			modifier: utils.round(0),
			onUpdate: function () {
				progress = counter.value;
			}
		});
		if (rewardIcon) {
			animate(rewardIcon, {
				scale: rewardIconScaleFinal,
				delay: 0,
				duration: 1500,
				ease: 'linear'
			}).then(() => {
				if (rewardIcon) {
					animate(rewardIcon, {
						rotate: [0, -5, 10, -10, 5, 0],
						duration: 500
					});
				}
			});
		}
	});
</script>

<Modal {onClose}>
	<div class="mt-2 flex w-3xs flex-col items-center justify-center">
		<!-- <div class="mb-4 text-3xl font-bold text-gray-900">Stage Completed</div> -->
		<GameModeIconTitle {icon} {iconId} {title} {subtitle} />
		<div class="text-xl font-bold text-gray-900">Cleared - {stageName}</div>
		<div class="mt-4 flex w-full flex-col items-start gap-1 px-1">
			<div class="ps-2 text-sm text-gray-500">Level progress {progress}%</div>
			<div class="relative min-h-4 w-full">
				<div
					bind:this={rewardIcon}
					class=" absolute -top-1.5 right-0 h-5 w-5"
					style="transform: scale({rewardIconScaleInitial});"
				>
					<LevelsRewardIcon fill="#c10007" />
				</div>
				<div class=" min-h-4 w-full overflow-hidden rounded-md bg-gray-300">
					<div
						class="progress-bar-fill h-4 rounded-e-md bg-green-500"
						style="width: {progress}%;"
					></div>
				</div>
			</div>
		</div>
		<button
			class="button-active mt-8 w-full rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white lg:mt-8"
			onclick={onPlayClick}
		>
			Next Level
		</button>
	</div>
</Modal>
