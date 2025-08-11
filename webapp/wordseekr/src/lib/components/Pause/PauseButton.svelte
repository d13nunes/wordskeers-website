<script lang="ts">
	import { isDarkMode } from '$lib/utils/darkmode';
	import PauseIcon from './PauseIcon.svelte';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();
</script>

<button {onclick}>
	<div
		class="button-active relative flex h-16 w-16 flex-col items-center justify-center rounded-lg surface px-4 py-2 shadow-sm {$isDarkMode ? 'bg-gray-700' : 'bg-white'}"
	>
		<div class="mb-4 w-4">
			<PauseIcon color={$isDarkMode ? '#d1d5dc' : '#000000'} />
		</div>
		<div class="absolute bottom-2 flex flex-col items-center justify-center">
			<span class="text-sm font-medium {$isDarkMode ? 'text-gray-300' : 'text-gray-500'}">Pause</span>
		</div>
	</div>
</button>
