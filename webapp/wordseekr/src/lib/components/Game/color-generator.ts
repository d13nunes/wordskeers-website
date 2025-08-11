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

class ColorGenerator {
	darkColors: ColorTheme[];
	lightColors: ColorTheme[];
	private useRedOnly: boolean = false;

	constructor() {
		this.lightColors = [
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
				bg: 'bg-cyan-300',
				text: 'text-cyan-700',
				hint: 'bg-cyan-100',
				isSelectedColor: 'bg-cyan-200',
				bgHex: '#67E8F9',
				textHex: '#0E7490',
				hintHex: '#CFFAFE',
				isSelectedColorHex: '#A5F3FC'
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
				bg: 'bg-emerald-300',
				text: 'text-emerald-700',
				hint: 'bg-emerald-100',
				isSelectedColor: 'bg-emerald-200',
				bgHex: '#6EE7B7',
				textHex: '#059669',
				hintHex: '#D9F99D',
				isSelectedColorHex: '#D9F99D'
			},
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
				bg: 'bg-amber-300',
				text: 'text-amber-700',
				hint: 'bg-amber-100',
				isSelectedColor: 'bg-amber-200',
				bgHex: '#F59E0B',
				textHex: '#92400E',
				hintHex: '#FEF3C7',
				isSelectedColorHex: '#FDE68A'
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
				bg: 'bg-red-300',
				text: 'text-red-700',
				hint: 'bg-red-100',
				isSelectedColor: 'bg-red-200',
				bgHex: '#FCA5A5',
				textHex: '#B91C1C',
				hintHex: '#FEE2E2',
				isSelectedColorHex: '#FECACA'
			}
		];

		this.darkColors = [
			{
				bg: 'bg-purple-700',
				text: 'text-purple-100',
				hint: 'bg-purple-900',
				isSelectedColor: 'bg-purple-600',
				bgHex: '#7C3AED',
				textHex: '#F3E8FF',
				hintHex: '#581C87',
				isSelectedColorHex: '#9333EA'
			},
			{
				bg: 'bg-indigo-700',
				text: 'text-indigo-100',
				hint: 'bg-indigo-900',
				isSelectedColor: 'bg-indigo-600',
				bgHex: '#4338CA',
				textHex: '#E0E7FF',
				hintHex: '#312E81',
				isSelectedColorHex: '#4F46E5'
			},
			{
				bg: 'bg-blue-700',
				text: 'text-blue-100',
				hint: 'bg-blue-900',
				isSelectedColor: 'bg-blue-600',
				bgHex: '#1D4ED8',
				textHex: '#DBEAFE',
				hintHex: '#1E3A8A',
				isSelectedColorHex: '#2563EB'
			},
			{
				bg: 'bg-cyan-700',
				text: 'text-cyan-100',
				hint: 'bg-cyan-900',
				isSelectedColor: 'bg-cyan-600',
				bgHex: '#0E7490',
				textHex: '#CFFAFE',
				hintHex: '#164E63',
				isSelectedColorHex: '#0891B2'
			},
			{
				bg: 'bg-teal-700',
				text: 'text-teal-100',
				hint: 'bg-teal-900',
				isSelectedColor: 'bg-teal-600',
				bgHex: '#0F766E',
				textHex: '#CCFBF1',
				hintHex: '#134E4A',
				isSelectedColorHex: '#0D9488'
			},
			{
				bg: 'bg-emerald-700',
				text: 'text-emerald-100',
				hint: 'bg-emerald-900',
				isSelectedColor: 'bg-emerald-600',
				bgHex: '#059669',
				textHex: '#D1FAE5',
				hintHex: '#064E3B',
				isSelectedColorHex: '#059669'
			},
			{
				bg: 'bg-green-700',
				text: 'text-green-100',
				hint: 'bg-green-900',
				isSelectedColor: 'bg-green-600',
				bgHex: '#15803D',
				textHex: '#DCFCE7',
				hintHex: '#14532D',
				isSelectedColorHex: '#16A34A'
			},
			{
				bg: 'bg-lime-700',
				text: 'text-lime-100',
				hint: 'bg-lime-900',
				isSelectedColor: 'bg-lime-600',
				bgHex: '#4D7C0F',
				textHex: '#ECFCCB',
				hintHex: '#365314',
				isSelectedColorHex: '#65A30D'
			},
			{
				bg: 'bg-yellow-700',
				text: 'text-yellow-100',
				hint: 'bg-yellow-900',
				isSelectedColor: 'bg-yellow-600',
				bgHex: '#A16207',
				textHex: '#FEF9C3',
				hintHex: '#713F12',
				isSelectedColorHex: '#CA8A04'
			},
			{
				bg: 'bg-amber-700',
				text: 'text-amber-100',
				hint: 'bg-amber-900',
				isSelectedColor: 'bg-amber-600',
				bgHex: '#92400E',
				textHex: '#FEF3C7',
				hintHex: '#78350F',
				isSelectedColorHex: '#D97706'
			},
			{
				bg: 'bg-orange-700',
				text: 'text-orange-100',
				hint: 'bg-orange-900',
				isSelectedColor: 'bg-orange-600',
				bgHex: '#C2410C',
				textHex: '#FFEDD5',
				hintHex: '#7C2D12',
				isSelectedColorHex: '#EA580C'
			},
			{
				bg: 'bg-red-700',
				text: 'text-red-100',
				hint: 'bg-red-900',
				isSelectedColor: 'bg-red-600',
				bgHex: '#B91C1C',
				textHex: '#FEE2E2',
				hintHex: '#7F1D1D',
				isSelectedColorHex: '#DC2626'
			}
		];
	}

	toggleRedOnly() {
		this.useRedOnly = !this.useRedOnly;
	}

	getBGColor(index: number, isDarkMode: boolean) {
		const colors = isDarkMode ? this.darkColors : this.lightColors;
		return colors[index % colors.length].bg;
	}

	getTextColor(index: number, isDarkMode: boolean) {
		const colors = isDarkMode ? this.darkColors : this.lightColors;
		return colors[index % colors.length].text;
	}

	getColor(index: number, isDarkMode: boolean) {
		const colors = isDarkMode ? this.darkColors : this.lightColors;
		return colors[index % colors.length];
	}

	isRedOnly() {
		return this.useRedOnly;
	}

	private index = 0;
	getNextColor(isDarkMode: boolean): ColorTheme {
		const colors = isDarkMode ? this.darkColors : this.lightColors;
		this.index = (this.index + 1) % colors.length;
		return colors[this.index];
	}
}

const colorGenerator = new ColorGenerator();

export default colorGenerator;
