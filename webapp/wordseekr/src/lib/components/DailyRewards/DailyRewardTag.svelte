<script lang="ts">
	import DailyRewardIcon from './DailyRewardIcon.svelte';
	interface Props {
		tag: string;
		onclick: () => void;
	}
	let { tag, onclick }: Props = $props();
</script>

<button class="card-button flex flex-row items-center justify-center gap-3" {onclick}>
	<div class="h-4 w-4 lg:h-6 lg:w-6">
		<DailyRewardIcon fill="#c10007" />
	</div>
	<span class="text-black-500 text-sm font-medium lg:text-lg">{tag}</span>
</button>
