<script lang="ts">
	export let title: string;
	export let detail: string;
	export let disabled: boolean = false;
	export let onClick: () => void;
</script>

<button
	class="flex flex-col items-stretch gap-2 rounded-xl border-[1px] border-gray-200 bg-gray-100 p-4 text-gray-400 active:bg-gray-200"
	onclick={onClick}
	{disabled}
>
	<!--!! icon -->
	<div class="flex flex-row items-center justify-between gap-4">
		<div class="flex flex-row items-center gap-4">
			<slot name="icon" />

			<div class="flex flex-col items-start gap-0">
				<span class="text-base leading-tight font-normal break-words text-gray-900">{title}</span>
				<span class="text-sm leading-snug font-light break-words text-gray-900">{detail}</span>
			</div>
		</div>
		<slot name="action" />
	</div>
</button>
