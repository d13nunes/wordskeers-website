<script lang="ts">
	import { animate, JSAnimation, utils } from 'animejs';
	import { onMount } from 'svelte';

	interface Props {
		previousProgressValue?: number;
		currentProgressValue: number;
		startAnimation?: boolean;
		class?: string;
		label?: string;
	}

	const {
		currentProgressValue,
		previousProgressValue = currentProgressValue,
		startAnimation,
		class: className,
		label = 'Level progress'
	}: Props = $props();

	let progress = $state(previousProgressValue);
	let progressAnimation: JSAnimation | null = null;

	function animateProgress(previous: number, current: number) {
		let counter = { value: previous };
		progressAnimation = animate(counter, {
			value: current,
			delay: 500,
			duration: 2000,
			ease: 'outQuad',
			modifier: utils.round(0),
			onUpdate: function () {
				progress = counter.value;
			}
		});
	}

	$effect(() => {
		if (startAnimation) {
			animateProgress(previousProgressValue, currentProgressValue);
		}
	});

	onMount(() => {
		if (startAnimation && !progressAnimation) {
			animateProgress(previousProgressValue, currentProgressValue);
		}
		return () => {
			progressAnimation?.cancel();
			progressAnimation = null;
		};
	});
</script>

<div class="flex w-full flex-col items-center justify-center gap-1 {className}">
	<div class="self-start ps-2 text-sm text-gray-500">{label} {progress}%</div>
	<div class=" min-h-4 w-full overflow-hidden rounded-md bg-gray-300">
		<div class="progress-bar-fill h-4 rounded-e-md bg-green-800" style="width: {progress}%;"></div>
	</div>
</div>
