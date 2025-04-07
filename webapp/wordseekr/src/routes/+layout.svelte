<script lang="ts">
	import type { Snippet } from 'svelte';
	import '../app.css';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';

	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();

	function onDailyRewardClick() {
		console.log('daily reward clicked');
	}
	function onStoreClick() {
		console.log('store clicked');
	}
</script>

<div class="pt-safe-top pb-safe-bottom px-safe-left pr-safe-right min-h-screen bg-slate-50">
	<div class="absolute top-16 right-4 flex flex-row gap-2 lg:top-8">
		<DailyRewardTag tag="Rewards" onclick={onDailyRewardClick} />
		<BalanceTag onclick={onStoreClick} />
	</div>
	{@render children()}
</div>
