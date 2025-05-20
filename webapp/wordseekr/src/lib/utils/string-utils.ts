export function toTitleCase(str: string) {
	return str.toLowerCase().replace(/\b\w/g, (char) => char.toUpperCase());
}

export function getFormatedTime(elapsedTime: number) {
	const minutes = Math.floor(elapsedTime / 60);
	const seconds = elapsedTime % 60;
	return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

export function getPositionId(row: number, col: number) {
	return `${row}.${col}`;
}
