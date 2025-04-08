<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';

	let balance = $state(0);
	walletStore.coins((newBalance) => (balance = newBalance));
</script>

<div class="dailyreward-card flex flex-col items-center gap-0 border-[1px] border-gray-200">
	<div class="flex flex-row items-baseline gap-2">
		<div class="w-6">
			<CoinsPileIcon />
		</div>
		<span class="text-3xl font-bold text-gray-800">{balance}</span>
	</div>
	<span class="text-xs font-light text-gray-500">Current Balance</span>
</div>
