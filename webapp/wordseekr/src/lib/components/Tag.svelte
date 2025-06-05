<script lang="ts">
	import Confetti from 'svelte-confetti';

	// Define theme name constants
	export const ThemeName = {
		Default: 'default',
		Red: 'red',
		Cyan: 'cyan',
		Emerald: 'emerald',
		Amber: 'amber'
	} as const;

	// Define the type for theme names

	interface Theme {
		bg: string;
		text: string;
	}

	// Define color themes
	const defaultTheme: Theme = {
		bg: 'bg-slate-200',
		text: 'text-gray-700'
	};

	interface Props {
		id: string;
		tag: string;
		bgColor?: string;
		textColor?: string;
		isDiscovered: boolean;
	}
	let { id, tag, isDiscovered, bgColor, textColor }: Props = $props();

	$effect(() => {
		bgColor = bgColor ? bgColor : defaultTheme.bg;
		textColor = textColor ? textColor : defaultTheme.text;
	});
</script>

<div
	{id}
	class="relative flex h-full items-center rounded-sm select-none {isDiscovered
		? 'opacity-50'
		: ''} rounded-md {bgColor} "
>
	{#if isDiscovered}
		<div class="absolute inset-0 z-10 flex items-center justify-center">
			<Confetti
				x={[-0.5, 0.5]}
				y={[0, 0.1]}
				fallDistance="25px"
				amount={50}
				size={5}
				duration={1000}
			/>
		</div>
	{/if}
	<span class="px-2 py-2 {isDiscovered ? 'line-through' : ''} font-regular text-xs/2 {textColor}"
		>{tag}</span
	>
</div>
