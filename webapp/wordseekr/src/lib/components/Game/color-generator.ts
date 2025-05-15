export interface ColorTheme {
	bg: string;
	text: string;
	hint: string;
	isSelectedColor: string;
	bgHex: string;
	textHex: string;
	hintHex: string;
	isSelectedColorHex: string;
}

const RED_THEME: ColorTheme = {
	bg: 'bg-indigo-300',
	text: 'text-indigo-700',
	hint: 'bg-indigo-100',
	isSelectedColor: 'bg-indigo-200',
	bgHex: '#A5B4FC',
	textHex: '#4338CA',
	hintHex: '#E0E7FF',
	isSelectedColorHex: '#C7D2FE'
};

export class ColorGenerator {
	colors: ColorTheme[];
	private useRedOnly: boolean = false;

	constructor() {
		this.colors = [
			RED_THEME,
			{
				bg: 'bg-green-300',
				text: 'text-green-700',
				hint: 'bg-green-100',
				isSelectedColor: 'bg-green-200',
				bgHex: '#86EFAC',
				textHex: '#15803D',
				hintHex: '#DCFCE7',
				isSelectedColorHex: '#BBF7D0'
			},
			{
				bg: 'bg-blue-300',
				text: 'text-blue-700',
				hint: 'bg-blue-100',
				isSelectedColor: 'bg-blue-200',
				bgHex: '#93C5FD',
				textHex: '#1D4ED8',
				hintHex: '#DBEAFE',
				isSelectedColorHex: '#BFDBFE'
			},
			{
				bg: 'bg-yellow-300',
				text: 'text-yellow-700',
				hint: 'bg-yellow-100',
				isSelectedColor: 'bg-yellow-200',
				bgHex: '#FDE047',
				textHex: '#A16207',
				hintHex: '#FEF9C3',
				isSelectedColorHex: '#FEF08A'
			},
			{
				bg: 'bg-purple-300',
				text: 'text-purple-700',
				hint: 'bg-purple-100',
				isSelectedColor: 'bg-purple-200',
				bgHex: '#D8B4FE',
				textHex: '#7E22CE',
				hintHex: '#F3E8FF',
				isSelectedColorHex: '#E9D5FF'
			},
			{
				bg: 'bg-orange-300',
				text: 'text-orange-700',
				hint: 'bg-orange-100',
				isSelectedColor: 'bg-orange-200',
				bgHex: '#FDBA74',
				textHex: '#C2410C',
				hintHex: '#FFE4E6',
				isSelectedColorHex: '#FED7AA'
			},
			{
				bg: 'bg-teal-300',
				text: 'text-teal-700',
				hint: 'bg-teal-100',
				isSelectedColor: 'bg-teal-200',
				bgHex: '#5EEAD4',
				textHex: '#0F766E',
				hintHex: '#CCFBF1',
				isSelectedColorHex: '#99F6E4'
			},
			{
				bg: 'bg-lime-300',
				text: 'text-lime-700',
				hint: 'bg-lime-100',
				isSelectedColor: 'bg-lime-200',
				bgHex: '#BEF264',
				textHex: '#4D7C0F',
				hintHex: '#ECFCCB',
				isSelectedColorHex: '#D9F99D'
			},
			{
				bg: 'bg-indigo-300',
				text: 'text-indigo-700',
				hint: 'bg-indigo-100',
				isSelectedColor: 'bg-indigo-200',
				bgHex: '#A5B4FC',
				textHex: '#4338CA',
				hintHex: '#E0E7FF',
				isSelectedColorHex: '#C7D2FE'
			},
			{
				bg: 'bg-cyan-300',
				text: 'text-cyan-700',
				hint: 'bg-cyan-100',
				isSelectedColor: 'bg-cyan-200',
				bgHex: '#67E8F9',
				textHex: '#0E7490',
				hintHex: '#CFFAFE',
				isSelectedColorHex: '#A5F3FC'
			}
		];
	}

	toggleRedOnly() {
		this.useRedOnly = !this.useRedOnly;
	}

	getBGColor(index: number) {
		return this.colors[index % this.colors.length].bg;
	}

	getTextColor(index: number) {
		return this.colors[index % this.colors.length].text;
	}

	getColor(index: number) {
		if (this.useRedOnly) {
			return RED_THEME;
		}
		return this.colors[index % this.colors.length];
	}

	isRedOnly() {
		return this.useRedOnly;
	}
}
