<script lang="ts">
	import '../app.css';

	import { fade, fly } from 'svelte/transition';
	import { cubicIn, cubicOut } from 'svelte/easing';

	interface Props {
		data: {
			pathname: string;
		};
	}

	let { data }: Props = $props();

	const duration = 300;
	const delay = duration + 100;
	const y = 10;

	const transitionIn = { easing: cubicOut, y, duration, delay };
	const transitionOut = { easing: cubicIn, y: -y, duration };
</script>

{#key data.pathname}
	<div class="pt-safe-top pb-safe-bottom px-safe-left pr-safe-right min-h-screen">
		<slot />
	</div>
{/key}
