<script lang="ts">
	interface Props {
		onResume: () => void;
		onNewGame: () => void;
	}

	let { onResume, onNewGame }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center">
	<h1>Pause Screen</h1>
	<button onclick={onResume}>Resume</button>
	<button onclick={onNewGame}>New Game</button>
</div>
