<script lang="ts">
	import Board from '$lib/components/Game/Board.svelte';

	const grid: string[][] = [
		['A', 'B', 'C'],
		['D', 'E', 'F'],
		['G', 'H', 'I']
	];
</script>

<div class="flex flex-col p-16">
	<Board {grid} />
</div>
