<script lang="ts">
	import PauseIcon from './PauseIcon.svelte';

	export let onClick: () => void;
</script>

<button on:click={onClick}>
	<div
		class="button-active flex h-28 w-28 flex-col items-center justify-center rounded-lg bg-white px-6 py-4 shadow-sm"
	>
		<div class="w-8">
			<PauseIcon />
		</div>
		<div class="flex flex-col items-center justify-center pt-3">
			<span class="text-sm font-medium text-gray-500">Pause</span>
		</div>
	</div>
</button>
