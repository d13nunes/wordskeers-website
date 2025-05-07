export interface ColorTheme {
	bg: string;
	text: string;
	hint: string;
	isSelectedColor: string;
}
export class ColorGenerator {
	colors: ColorTheme[];
	constructor() {
		this.colors = [
			{
				bg: 'bg-red-300',
				text: 'text-red-700',
				hint: 'bg-red-100',
				isSelectedColor: 'bg-red-200'
			},
			{
				bg: 'bg-green-300',
				text: 'text-green-700',
				hint: 'bg-green-100',
				isSelectedColor: 'bg-green-200'
			},
			{
				bg: 'bg-blue-300',
				text: 'text-blue-700',
				hint: 'bg-blue-100',
				isSelectedColor: 'bg-blue-200'
			},
			{
				bg: 'bg-yellow-300',
				text: 'text-yellow-700',
				hint: 'bg-yellow-100',
				isSelectedColor: 'bg-yellow-200'
			},
			{
				bg: 'bg-purple-300',
				text: 'text-purple-700',
				hint: 'bg-purple-100',
				isSelectedColor: 'bg-purple-200'
			},
			{
				bg: 'bg-orange-300',
				text: 'text-orange-700',
				hint: 'bg-orange-100',
				isSelectedColor: 'bg-orange-200'
			},
			{
				bg: 'bg-teal-300',
				text: 'text-teal-700',
				hint: 'bg-teal-100',
				isSelectedColor: 'bg-teal-200'
			},
			{
				bg: 'bg-lime-300',
				text: 'text-lime-700',
				hint: 'bg-lime-100',
				isSelectedColor: 'bg-lime-200'
			},
			{
				bg: 'bg-indigo-300',
				text: 'text-indigo-700',
				hint: 'bg-indigo-100',
				isSelectedColor: 'bg-indigo-200'
			},
			{
				bg: 'bg-cyan-300',
				text: 'text-cyan-700',
				hint: 'bg-cyan-100',
				isSelectedColor: 'bg-cyan-200'
			}
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
