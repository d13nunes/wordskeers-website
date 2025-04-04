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

	// Define color themes
	const themes: Record<ThemeName, Theme> = {
		default: {
			bg: 'bg-slate-100',
			text: 'text-slate-700'
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
		customBg?: string;
		customText?: string;
		isDiscovered: boolean;
	}
	let { tag, isDiscovered, customBg, customText, variant = ThemeName.Default }: Props = $props();
	// export let tag: string = 'default';
	// export let variant: ThemeName = ThemeName.Default;
	// export let customBg = null;
	// export let customText = null;
	// export let isDiscovered: boolean = false;

	// Use custom colors if provided, otherwise use the theme
	let theme = getTheme(variant);
	let bgColor = customBg || theme.bg;
	let textColor = customText || theme.text;

	interface Theme {
		bg: string;
		text: string;
	}
</script>

<div
	class="flex h-full items-center select-none {isDiscovered
		? 'opacity-50'
		: ''} rounded-xl {bgColor}"
>
	<span
		class="px-4 py-1 font-[Inter] {isDiscovered
			? 'line-through'
			: ''} text-sm font-medium {textColor}">{tag}</span
	>
</div>
