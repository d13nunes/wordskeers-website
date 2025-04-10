<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import LockIcon from './LockIcon.svelte';

	let { title, detail } = $props<{
		title: string;
		detail: string;
	}>();

	let disabled = $state(true);
	let onClick = $state(() => {});
</script>

<SmallCard {title} {detail} {disabled} {onClick} class="disabled:opacity-50">
	{#snippet icon()}
		<div class="h-5 w-4">
			<LockIcon />
		</div>
	{/snippet}
	{#snippet action()}
		<div class="small-card-action bg-gray-200 text-gray-400">Locked</div>
	{/snippet}
</SmallCard>
