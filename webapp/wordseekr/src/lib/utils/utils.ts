import { Capacitor } from '@capacitor/core';

export function getIsSmallScreen() {
	const smallWidth = 1134;
	const isSmallScreen = Capacitor.isNativePlatform() && window.innerWidth < smallWidth;
	return isSmallScreen;
}
