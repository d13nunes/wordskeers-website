<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import LockIcon from './LockIcon.svelte';

	interface Props {
		title: string;
		detail: string;
	}
	const { title, detail }: Props = $props();

	let disabled = $state(true);
	let onClick = $state(() => {});
</script>

<SmallCard
	{title}
	{detail}
	{disabled}
	iconBGColor="bg-emerald-100"
	{onClick}
	class="disabled:opacity-50"
>
	{#snippet icon()}
		<div class="h-5 w-4">
			<LockIcon />
		</div>
	{/snippet}
	{#snippet action()}
		<div class="small-card-action bg-emerald-100 text-emerald-500">Claimed</div>
	{/snippet}
</SmallCard>
