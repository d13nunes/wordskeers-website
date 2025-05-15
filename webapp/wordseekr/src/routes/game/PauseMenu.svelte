<script lang="ts">
	import { goto } from '$app/navigation';
	import { cubicOut, cubicIn, cubicInOut } from 'svelte/easing';
	import { fade, scale } from 'svelte/transition';

	interface Props {
		onClickResume: () => void;
		onClickNewGame: () => void;
	}

	const { onClickResume, onClickNewGame }: Props = $props();
</script>

<div
	in:fade={{ duration: 300, easing: cubicOut }}
	out:fade={{ delay: 100, duration: 300, easing: cubicIn }}
	class="bg-opacity-50 fixed inset-0 z-50 flex items-center justify-center bg-black"
>
	<div
		in:scale={{ delay: 100, duration: 300, easing: cubicInOut }}
		out:scale={{ duration: 300, easing: cubicInOut }}
		class="flex flex-col items-center gap-4 rounded-lg bg-white p-8 shadow-lg"
	>
		<h2 class="mb-4 text-2xl font-bold">Game Paused</h2>
		<div class="flex flex-row gap-4">
			<button
				class="rounded bg-red-500 px-4 py-2 text-white hover:bg-red-600"
				onclick={onClickNewGame}
			>
				New Game
			</button>
			<button
				class="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
				onclick={onClickResume}
			>
				Resume Game
			</button>
		</div>
	</div>
</div>
