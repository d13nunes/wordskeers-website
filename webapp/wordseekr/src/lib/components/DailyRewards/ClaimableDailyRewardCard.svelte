<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	export let title: string;
	export let detail: string;
	export let isAd: boolean;
	export let onClick: () => void;
</script>

<SmallCard {title} {detail} {onClick}>
	<div slot="icon">
		<div class="h-5 w-5">
			<CoinsPileIcon />
		</div>
	</div>
	<div slot="action">
		{#if isAd}
			<div class="min-w-[100px] rounded-md bg-emerald-700 px-4 py-2 text-white">Watch Ad</div>
		{:else}
			<div class="min-w-[100px] rounded-md bg-blue-600 px-4 py-2 text-white">Claim</div>
		{/if}
	</div>
</SmallCard>
