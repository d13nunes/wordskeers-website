import { writable, get } from 'svelte/store';

export type Theme = 'light' | 'dark' | 'system';

const THEME_KEY = 'theme';

// Get initial theme from localStorage or default to system
function getInitialTheme(): Theme {
	if (typeof window === 'undefined') {
		return 'system';
	}

	const stored = localStorage.getItem(THEME_KEY);
	if (stored === 'light' || stored === 'dark' || stored === 'system') {
		return stored;
	}
	return 'system';
}

// Create the theme store
export const theme = writable<Theme>(getInitialTheme());

// Subscribe to theme changes and apply them
theme.subscribe((newTheme) => {
	if (typeof window === 'undefined') {
		return;
	}

	// Save to localStorage
	localStorage.setItem(THEME_KEY, newTheme);

	// Apply theme to document
	applyTheme(newTheme);
});

// Apply the theme to the document
function applyTheme(theme: Theme) {
	const root = document.documentElement;

	// Remove existing theme classes
	root.classList.remove('light', 'dark');

	if (theme === 'system') {
		// Use system preference
		const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
		root.classList.add(isDark ? 'dark' : 'light');
	} else {
		// Use explicit theme
		root.classList.add(theme);
	}
}

// Listen for system theme changes
if (typeof window !== 'undefined') {
	window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
		const currentTheme = get(theme);
		if (currentTheme === 'system') {
			applyTheme('system');
		}
	});
}

// Initialize theme on app start
if (typeof window !== 'undefined') {
	applyTheme(getInitialTheme());
}

// Helper function to get current theme
export function getCurrentTheme(): Theme {
	return get(theme);
}

// Helper function to toggle between light and dark
export function toggleTheme() {
	const currentTheme = get(theme);
	if (currentTheme === 'system') {
		// If system, switch to explicit light
		theme.set('light');
	} else if (currentTheme === 'light') {
		// If light, switch to dark
		theme.set('dark');
	} else {
		// If dark, switch to light
		theme.set('light');
	}
}

// Helper function to set specific theme
export function setTheme(newTheme: Theme) {
	theme.set(newTheme);
}
