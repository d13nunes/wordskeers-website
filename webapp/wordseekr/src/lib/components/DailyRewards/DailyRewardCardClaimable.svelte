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
			<div class="small-card-action bg-emerald-700 text-white">Watch Ad</div>
		{:else}
			<div class="small-card-action bg-blue-600 text-white">Collect</div>
		{/if}
	{/snippet}
</SmallCard>
