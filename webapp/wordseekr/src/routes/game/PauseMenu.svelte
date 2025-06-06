<script lang="ts">
	import Modal from '$lib/components/Modal.svelte';

	interface Props {
		onClickResume: () => void;
		onClickNewGame: () => void;
	}

	const { onClickResume, onClickNewGame }: Props = $props();
</script>

<Modal>
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
</Modal>
