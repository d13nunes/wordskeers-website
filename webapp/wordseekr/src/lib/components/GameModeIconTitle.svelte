<script lang="ts">
	import { fade } from 'svelte/transition';

	interface Props {
		icon?: string;
		iconId?: string;
		title?: string;
		subtitle: string;
	}
	let { icon, iconId, title, subtitle }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center">
	{#if icon}
		<img
			id={iconId}
			src={icon}
			alt="Logo"
			class="pointer-events-none mb-1 aspect-square h-24 w-24 object-contain lg:h-32 lg:w-32"
		/>
	{/if}
	<div class="flex flex-col items-center justify-center gap-1 lg:gap-1">
		<span in:fade class="text-5xl font-bold lg:text-6xl">{title}</span>
		{#if title}{/if}
		<span class="text-sm text-gray-500 lg:text-base">{subtitle}</span>
	</div>
</div>
