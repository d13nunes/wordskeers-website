<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import Confetti from 'svelte-confetti';

	let balance = $state(0);
	let firstUpdate = true;
	let showConfetti = $state(false);
	walletStore.coins((newBalance) => {
		balance = newBalance;
		if (firstUpdate) {
			firstUpdate = false;
			return;
		}
		showConfetti = true;
		setTimeout(() => {
			showConfetti = false;
		}, 1000);
	});
</script>

<div
	class="dailyreward-card relative flex flex-col items-center gap-0 border-[1px] border-gray-200"
>
	{#if showConfetti}
		<div class="absolute top-20 z-10">
			<Confetti amount={200} size={20} />
		</div>
	{/if}
	<div class="flex flex-row items-baseline gap-2">
		<div class="w-6">
			<CoinsPileIcon />
		</div>
		<span class="text-3xl font-bold text-gray-800">{balance}</span>
	</div>
	<span class="text-xs font-light text-gray-500">Current Balance</span>
</div>
