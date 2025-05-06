export function randomFromStringArray(array: string[]) {
	return array[Math.floor(Math.random() * array.length)];
}
export function randomInt(max: number, min: number = 0): number {
	// Ensure min is less than max
	if (min > max) {
		[min, max] = [max, min];
	}
	// Generate random number in range [min, max]
	return Math.floor(Math.random() * (max - min + 1)) + min;
}
