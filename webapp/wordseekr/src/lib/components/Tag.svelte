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
	type ThemeName = (typeof ThemeName)[keyof typeof ThemeName];

	interface Theme {
		bg: string;
		text: string;
	}

	// Define color themes
	const themes: Record<ThemeName, Theme> = {
		default: {
			bg: 'bg-slate-200',
			text: 'text-gray-900'
		},
		red: {
			bg: 'bg-red-100',
			text: 'text-red-700'
		},
		cyan: {
			bg: 'bg-cyan-100',
			text: 'text-cyan-700'
		},
		emerald: {
			bg: 'bg-emerald-100',
			text: 'text-emerald-700'
		},
		amber: {
			bg: 'bg-amber-100',
			text: 'text-amber-700'
		}
	};

	function getTheme(themeName: string): Theme {
		if (!(themeName in themes)) {
			console.error(`Invalid theme name: ${themeName}`);
			return themes.default;
		}
		return themes[themeName as ThemeName];
	}
	interface Props {
		tag: string;
		variant?: ThemeName;
		bgColor?: string;
		textColor?: string;
		isDiscovered: boolean;
	}
	let { tag, isDiscovered, bgColor, textColor, variant = ThemeName.Default }: Props = $props();

	let theme = getTheme(variant);
	$effect(() => {
		bgColor = bgColor ? bgColor : theme.bg;
		textColor = textColor ? textColor : theme.text;
	});
</script>

<div
	class="flex h-full items-center transition-colors duration-300 ease-in-out select-none {isDiscovered
		? 'opacity-50'
		: ''} rounded-xl {bgColor} "
>
	<span
		class="px-2 py-1 font-[Inter] transition-all duration-300 ease-in-out {isDiscovered
			? 'line-through'
			: ''} text-xs font-thin {textColor}">{tag}</span
	>
</div>
