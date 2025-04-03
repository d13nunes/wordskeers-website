<script lang="ts">
	export let grid: string[][];
</script>

<div class="flex flex-col items-center justify-center">
	<div class="card grid grid-cols-3 gap-2">
		{#each grid as row}
			{#each row as cell}
				<div class="flex h-16 w-16 items-center justify-center bg-blue-100">{cell}</div>
			{/each}
		{/each}
	</div>
</div>
