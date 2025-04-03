<script lang="ts">
	export let title: string;
	export let detail: string;
	export let disabled: boolean = false;
	export let onClick: () => void;
</script>

<button
	class="flex flex-col items-stretch gap-2 rounded-lg border-[1px] border-amber-200 bg-amber-100 p-4 active:bg-amber-200
    disabled:border-gray-200 disabled:bg-gray-100 disabled:text-gray-400"
	onclick={onClick}
	{disabled}
>
	<!--!! icon -->
	<div class="flex flex-row items-center justify-between gap-4">
		<div class="flex flex-row items-center gap-4">
			<div class="flex h-12 w-12 items-center justify-center rounded-full bg-gray-50">
				<slot name="icon" />
			</div>

			<div class="flex flex-col items-start gap-0">
				<span class="text-base leading-tight font-bold break-words text-gray-700">{title}</span>
				<span class="text-sm leading-snug font-normal break-words text-gray-700">{detail}</span>
			</div>
		</div>
		<slot name="action" />
	</div>
</button>
