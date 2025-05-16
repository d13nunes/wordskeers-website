<script lang="ts">
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
		tag: string;
		bgColor?: string;
		textColor?: string;
		isDiscovered: boolean;
	}
	let { tag, isDiscovered, bgColor, textColor }: Props = $props();

	$effect(() => {
		bgColor = bgColor ? bgColor : defaultTheme.bg;
		textColor = textColor ? textColor : defaultTheme.text;
	});
</script>

<div
	class="flex h-full items-center rounded-sm transition-colors duration-300 ease-in-out select-none {isDiscovered
		? 'opacity-50'
		: ''} rounded-md {bgColor} "
>
	<span
		class="px-2 py-2 transition-all duration-300 ease-in-out {isDiscovered
			? 'line-through'
			: ''} font-regular text-xs/2 {textColor}">{tag}</span
	>
</div>
