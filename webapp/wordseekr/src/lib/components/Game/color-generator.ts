export interface ColorTheme {
	bg: string;
	text: string;
}
export class ColorGenerator {
	colors: ColorTheme[];
	constructor() {
		this.colors = [
			{ bg: 'bg-red-300', text: 'text-red-700' },
			{ bg: 'bg-green-300', text: 'text-green-700' },
			{ bg: 'bg-blue-300', text: 'text-blue-700' },
			{ bg: 'bg-yellow-300', text: 'text-yellow-700' },
			{ bg: 'bg-purple-300', text: 'text-purple-700' }
		];
	}

	getBGColor(index: number) {
		return this.colors[index % this.colors.length].bg;
	}

	getTextColor(index: number) {
		return this.colors[index % this.colors.length].text;
	}

	getColor(index: number) {
		return this.colors[index % this.colors.length];
	}
}
