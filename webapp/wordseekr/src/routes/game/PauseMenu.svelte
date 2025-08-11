<script lang="ts">
	import Modal from '$lib/components/Modal.svelte';
	import { gameCounter } from '$lib/storage/local-storage';
	import { onMount } from 'svelte';

	interface Props {
		onClickResume: () => void;
		onClickNewGame: () => void;
	}

	const { onClickResume, onClickNewGame }: Props = $props();
	let showMainButton = $state(false);
	onMount(async () => {
		const isNewUser = (await gameCounter.getCount()) === 0;
		showMainButton = !isNewUser;
	});
</script>

<Modal onDismiss={onClickResume}>
	<h2 class=" text-2xl font-bold">Game Paused</h2>
	<div class="mb-4 text-sm text-gray-500 max-w-[200px] text-center">
		You'll lose your progress by navigating to main menu.
	</div>
	
	<div class="flex flex-row gap-4">
		{#if showMainButton}
			<button
				class="rounded bg-red-700 px-4 py-2 text-white hover:bg-red-800 dark:bg-red-600 dark:hover:bg-red-700"
				onclick={onClickNewGame}
			>
				Main Menu
			</button>
		{/if}
		<button
			class="rounded bg-blue-700 px-4 py-2 text-white hover:bg-blue-800 dark:bg-blue-600 dark:hover:bg-blue-700"
			onclick={onClickResume}
		>
			Resume
		</button>
	</div>
</Modal>
