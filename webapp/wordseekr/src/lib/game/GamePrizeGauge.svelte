<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	interface Props {
		value: number;
	}

	let { value } = $props();
</script>

<div class="flex h-16 max-w-16 min-w-16 items-center justify-center rounded-full bg-gray-100">
	<div class="relative">
		<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
			<div class="coin-icon h-6 w-6">
				<CoinsPileIcon />
			</div>
		</div>
		<span
			class="absolute top-1/2 left-1/2 mt-[14px] -translate-x-1/2 -translate-y-1/2 text-center font-bold text-gray-700"
			style="font-family: 'JetBrains Mono', 'Fira Code', 'Source Code Pro', monospace; font-size: 1.25rem; text-shadow: 1px 1px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff;"
			>{value}</span
		>
	</div>
</div>
