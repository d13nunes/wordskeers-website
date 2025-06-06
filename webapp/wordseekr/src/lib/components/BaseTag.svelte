<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		onclick: () => void;
		children: Snippet;
		disabled?: boolean;
		id?: string;
	}
	let { onclick, children, disabled, id }: Props = $props();
</script>

<button
	class="card-button flex h-8 flex-row items-center justify-center lg:h-12"
	{onclick}
	{disabled}
	{id}
>
	{@render children()}
</button>
