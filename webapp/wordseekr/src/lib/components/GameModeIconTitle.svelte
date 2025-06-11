<script lang="ts">
	interface Props {
		icon: string;
		iconId: string;
		title: string;
		subtitle: string;
	}
	let { icon, iconId, title, subtitle }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center">
	<img
		id={iconId}
		src={icon}
		alt="Logo"
		class="mb-1 aspect-square h-24 w-24 object-contain lg:h-32 lg:w-32"
	/>
	<div class="flex flex-col items-center justify-center gap-1 lg:gap-1">
		<span class="text-5xl font-bold lg:text-6xl">{title}</span>
		<span class="text-sm text-gray-500 lg:text-base">{subtitle}</span>
	</div>
</div>
