export function toTitleCase(str: string) {
	return str.toLowerCase().replace(/\b\w/g, (char) => char.toUpperCase());
}

export function getFormatedTime(elapsedTime: number) {
	let time = '';
	const hours = Math.floor(elapsedTime / 3600);
	if (hours > 0) {
		time += `${hours.toString().padStart(2, '0')}:`;
	}
	const minutes = Math.floor((elapsedTime % 3600) / 60);
	if (minutes > 0) {
		time += `${minutes.toString().padStart(2, '0')}:`;
	}
	const seconds = elapsedTime % 60;

	time += `${seconds.toString().padStart(2, '0')}`;

	return time;
}

export function getPositionId(row: number, col: number) {
	return `${row}.${col}`;
}
