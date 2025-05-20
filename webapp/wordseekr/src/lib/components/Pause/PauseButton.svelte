<script lang="ts">
	import PauseIcon from './PauseIcon.svelte';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();
</script>

<button {onclick}>
	<div
		class="button-active relative flex h-16 w-16 flex-col items-center justify-center rounded-lg bg-white px-4 py-2 shadow-sm"
	>
		<div class="mb-4 w-4">
			<PauseIcon />
		</div>
		<div class="absolute bottom-2 flex flex-col items-center justify-center">
			<span class="text-sm font-medium text-gray-500">Pause</span>
		</div>
	</div>
</button>
