<script lang="ts">
	import DailyRewardIcon from './DailyRewardIcon.svelte';

	export let tag: string;
	export let onClick: () => void;
</script>

<button class="card-button flex flex-row items-center justify-center gap-3" onclick={onClick}>
	<div class="h-4 w-4">
		<DailyRewardIcon fill="#c10007" />
	</div>
	<span class="text-black-500 text-sm font-medium">{tag}</span>
</button>
