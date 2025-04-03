<script lang="ts">
	import SmallCard from '$lib/components/SmallCard.svelte';
	import BellIcon from '$lib/components/Icons/BellIcon.svelte';

	export let onClick: () => void = () => {};

	const title: string = 'Enable notification';
	const detail: string = 'Never miss a reward!';
</script>

<SmallCard {title} {detail} disabled={false} {onClick}>
	<div slot="icon">
		<div class=" h-5 w-5">
			<BellIcon />
		</div>
	</div>
	<div slot="action">
		<div class="rounded-md bg-blue-600 px-4 py-2 text-white">Enable</div>
	</div>
</SmallCard>
