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

export function formatedBalance(balance: number) {
	// if balance is less than 1000, return the balance
	if (balance < 1000) {
		return balance.toString();
	}
	// each 1000 add a space
	const balanceString = balance.toString().split('').reverse().join('');
	let formattedBalance = balanceString.slice(0, 3);
	for (let i = 3; i < balanceString.length; i += 3) {
		formattedBalance += ' ' + balanceString.slice(i, i + 3);
	}
	formattedBalance = formattedBalance.split('').reverse().join('');
	return formattedBalance;
}

export function getPositionId(row: number, col: number) {
	return `${row}.${col}`;
}
