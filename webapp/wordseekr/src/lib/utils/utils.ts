import { Capacitor } from '@capacitor/core';

export function getIsSmallScreen() {
	const smallWidth = 957;
	const isSmallScreen = Capacitor.isNativePlatform() && window.innerWidth < smallWidth;
	console.log(
		'!!!- isSmallScreen',
		isSmallScreen,
		Capacitor.getPlatform(),
		window.innerWidth,
		window.innerHeight
	);
	return isSmallScreen;
}
