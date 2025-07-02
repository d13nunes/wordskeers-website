import { Capacitor } from '@capacitor/core';

export function getIsSmallScreen() {
	// const smallWidth = 1134;
	const isSmallScreen = Capacitor.isNativePlatform(); // && window.innerWidth < smallWidth;
	return isSmallScreen;
}

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
