import { Capacitor } from '@capacitor/core';

export function getIsSmallScreen() {
	// const smallWidth = 1134;
	const isSmallScreen = Capacitor.isNativePlatform(); // && window.innerWidth < smallWidth;
	return isSmallScreen;
}

export const adsIconBase64 =
	'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nO3ZP0oDQRiG8UGwsFKwsLD2AF7AC5hoZesVvIIgAVtLW0tvoOCfTg9gr2BjYaNJYSH+ZEgCi42bqNmZdZ5+v92H9/t2Z3ZCKBQKU4FtXGOgeQa4QndSiUPp0pskidTp1BGJ7ZQ6l3VE+tLntY5IFoQikhihJPKPEuniXu4iYXjtAvbx9ruPPWORSo01nE1bKxmRSq3Ybo/T1kxGZFRvEUd4z1pkDNZxk71IBHPYxXPWImOwjGN8ZC0yBhu4y14kgnnsTbp9CKmJVO67ipO2iJxmK9KK1pL7sGNlNA95vn614YNouES5/alAYyJYyn7RiB08/aZAExur82lrNS7Siq0utvBgRoQ/FJkpoYgkRiiJZJhIX/q81BGJp6epc1FHJP4dTJ3Nb0VGMj3pclBLoiLTiaenicxMP7ZT7SQKhUL4yieOYHQusx8oEQAAAABJRU5ErkJggg==';

export function normalizeQuoteText(
	quote: { text: string; isHidden: boolean; isDiscovered?: boolean }[]
): { text: string; isHidden: boolean; isDiscovered: boolean }[] {
	const punctuation = [
		',',
		'!',
		'?',
		'.',
		"'",
		';',
		':',
		'"',
		'(',
		')',
		'-',
		'—',
		'…',
		'[',
		']',
		'{',
		'}'
	];
	const normalizedQuote: { text: string; isHidden: boolean; isDiscovered: boolean }[] = [];
	for (const index in quote) {
		const segment = quote[index];
		const text = segment.text;
		const isPreviousHidden = normalizedQuote[normalizedQuote.length - 1]?.isHidden;
		if (punctuation.includes(text) && !isPreviousHidden) {
			console.log(text);
			// go to the previous segment and merge it with the current segment
			const previousSegment = normalizedQuote[normalizedQuote.length - 1];
			if (previousSegment) {
				previousSegment.text += text;
			} else {
				normalizedQuote.push({
					text: text,
					isHidden: segment.isHidden,
					isDiscovered: segment.isDiscovered ?? false
				});
			}
		} else {
			normalizedQuote.push({
				text: text,
				isHidden: segment.isHidden,
				isDiscovered: segment.isDiscovered ?? false
			});
		}
	}
	console.log(normalizedQuote);
	return normalizedQuote;
}
