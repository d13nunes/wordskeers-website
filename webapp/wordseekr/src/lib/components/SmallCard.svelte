<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		title: string;
		detail: string;
		disabled?: boolean;
		iconBGColor?: string;
		onClick: () => void;
		icon?: Snippet;
		action?: Snippet;
		class?: string;
	}
	let {
		title,
		detail,
		disabled = false,
		iconBGColor = 'bg-gray-50',
		onClick,
		icon,
		action,
		class: _class
	}: Props = $props();
</script>

<button
	class="flex flex-col items-stretch gap-2 rounded-lg border-[1px] border-amber-200 bg-amber-100 p-4 active:bg-amber-200
    disabled:border-gray-200 disabled:bg-gray-100 disabled:text-gray-400 max-[24rem]:px-4 max-[24rem]:py-2 {_class}"
	onclick={onClick}
	{disabled}
>
	<!--!! icon -->
	<div class="flex flex-row items-center justify-between gap-4">
		<div class="flex flex-row items-center gap-4">
			<div
				class="flex h-12 w-12 items-center justify-center rounded-full {iconBGColor} max-[24rem]:h-10 max-[24rem]:w-10"
			>
				{@render icon?.()}
			</div>
			<div class="flex flex-col items-start gap-0.5">
				<span class="text-start text-base leading-tight font-bold text-gray-700 max-[24rem]:text-xs"
					>{title}</span
				>
				<span
					class="max-[24rem]:text-tiny text-start text-sm leading-tight font-normal text-balance text-gray-700"
					>{detail}</span
				>
			</div>
		</div>
		{@render action?.()}
	</div>
</button>
