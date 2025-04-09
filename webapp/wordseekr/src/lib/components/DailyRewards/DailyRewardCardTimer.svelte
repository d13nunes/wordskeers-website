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
	});

	onDestroy(() => {
		if (interval) clearInterval(interval);
	});
</script>

<SmallCard {title} {detail} disabled={true} {onClick} class="bg-blue-100">
	{#snippet icon()}
		<div class="h-5 w-5">
			<ClockIcon />
		</div>
	{/snippet}
	{#snippet action()}
		<div class="min-w-[100px] rounded-md bg-blue-700 px-4 py-2 font-mono font-bold text-white">
			{timeRemaining}
		</div>
	{/snippet}
</SmallCard>
