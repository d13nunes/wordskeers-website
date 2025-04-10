<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import BellIcon from '$lib/components/Icons/BellIcon.svelte';

	let { onClick = () => {} } = $props<{
		onClick: () => void;
	}>();

	const title = 'Enable notification';
	const detail = 'Never miss a reward!';
</script>

<SmallCard {title} {detail} disabled={false} {onClick}>
	{#snippet icon()}
		<div class=" h-5 w-5">
			<BellIcon />
		</div>
	{/snippet}
	{#snippet action()}
		<div class="small-card-action bg-blue-600 text-white">Enable</div>
	{/snippet}
</SmallCard>
