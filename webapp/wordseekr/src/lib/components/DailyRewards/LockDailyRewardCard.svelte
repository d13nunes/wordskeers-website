<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import LockIcon from './LockIcon.svelte';
	export let title: string;
	export let detail: string;
	let disabled = true;
	let onClick: () => void = () => {};
</script>

<SmallCard {title} {detail} {disabled} {onClick}>
	<div slot="icon">
		<div class="h-5">
			<div class=" h-5 w-4">
				<LockIcon />
			</div>
		</div>
	</div>
	<div slot="action">
		<div class="rounded-md bg-gray-200 px-4 py-2 text-gray-400">Locked</div>
	</div>
</SmallCard>
