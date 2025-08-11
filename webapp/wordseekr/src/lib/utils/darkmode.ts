import { mode, setMode } from 'mode-watcher';
import { writable, type Writable } from 'svelte/store';

export const currentMode: Writable<string> = writable(mode.current);
let _currentMode = 'light';
currentMode.subscribe((value) => {
	_currentMode = value;
});

export const isDarkMode: Writable<boolean> = writable(_currentMode === 'dark');

export function toggleMode() {
	const newMode = _currentMode === 'dark' ? 'light' : 'dark';
	isDarkMode.set(newMode === 'dark');
	setMode(newMode);
	currentMode.set(newMode);
}
