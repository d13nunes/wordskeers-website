<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';

	let { title, detail, isAd, onClick } = $props<{
		title: string;
		detail: string;
		isAd: boolean;
		onClick: () => void;
	}>();
</script>

<SmallCard {title} {detail} {onClick}>
	{#snippet icon()}
		<div class="h-5 w-5">
			<CoinsPileIcon />
		</div>
	{/snippet}
	{#snippet action()}
		{#if isAd}
			<div class="min-w-[100px] rounded-md bg-emerald-700 px-4 py-2 text-white">Watch Ad</div>
		{:else}
			<div class="min-w-[100px] rounded-md bg-blue-600 px-4 py-2 text-white">Collect Now</div>
		{/if}
	{/snippet}
</SmallCard>
