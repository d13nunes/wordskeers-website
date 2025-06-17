<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import type { Snippet } from 'svelte';

	interface Props {
		children: Snippet;
		onPlayClick: () => void;
		title: string;
		icon?: string;
		iconId?: string;
		subtitle?: string;
	}

	const { onPlayClick, icon, iconId, children, title, subtitle = 'Game Mode' }: Props = $props();
</script>

<div class="flex h-full items-center justify-center sm:items-center lg:items-center lg:pb-0">
	<div class="flex w-2xs flex-col items-center justify-center">
		<GameModeIconTitle {icon} {iconId} {title} {subtitle} />

		{@render children()}
		<button
			class="button-active mt-6 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white lg:mt-8"
			onclick={onPlayClick}
		>
			Play
		</button>
	</div>
</div>
