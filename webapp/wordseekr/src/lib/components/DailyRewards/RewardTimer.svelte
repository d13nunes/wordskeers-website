<script lang="ts">
	import ClockIcon from '$lib/components/Icons/ClockIcon.svelte';
	import SmallCard from '$lib/components/SmallCard.svelte';
	import { onMount, onDestroy } from 'svelte';

	let { endDate } = $props<{
		endDate?: Date;
	}>();

	const title = 'Next Reward';
	const detail = 'Time Remaining';
	const onClick = $state(() => {});

	let timeRemaining = $state('');
	let interval: ReturnType<typeof setInterval>;

	function updateTimeRemaining() {
		const now = new Date();
		const diff = endDate.getTime() - now.getTime();

		if (diff <= 0) {
			timeRemaining = 'Ready!';
			return;
		}

		const hours = Math.floor(diff / (1000 * 60 * 60));
		const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
		const seconds = Math.floor((diff % (1000 * 60)) / 1000);

		timeRemaining = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
	}

	onMount(() => {
		updateTimeRemaining();
		interval = setInterval(updateTimeRemaining, 1000);
		return () => {
			if (interval) {
				clearInterval(interval);
			}
		};
	});
</script>

<button onclick={onClick} disabled={true} class="w-full bg-blue-100">
	<div class="small-card-action bg-blue-700 font-mono font-semibold text-white">
		{timeRemaining}
	</div>
</button>
