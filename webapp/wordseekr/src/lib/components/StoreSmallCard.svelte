<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		title: string;
		detail: string;
		disabled?: boolean;
		onclick: () => void;
		icon: Snippet;
		action: Snippet;
	}
	let { title, detail, disabled = false, onclick, icon, action }: Props = $props();
</script>

<button
	class="flex flex-col items-stretch gap-2 rounded-xl border-[1px] border-gray-200 bg-gray-100 p-4 text-gray-400 active:bg-gray-200 max-[24rem]:p-3"
	{onclick}
	{disabled}
>
	<!--!! icon -->
	<div class="flex flex-row items-center justify-between gap-4">
		<div class="flex flex-row items-center gap-4">
			{@render icon()}

			<div class="flex flex-col items-start gap-0">
				<span
					class="text-base leading-tight font-normal break-words text-gray-900 max-[24rem]:text-sm"
					>{title}</span
				>
				<span
					class="max-[24rem]:text-tiny text-sm leading-snug font-light break-words text-gray-900"
					>{detail}</span
				>
			</div>
		</div>
		{@render action()}
	</div>
</button>
