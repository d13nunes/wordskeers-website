export interface PowerUp {
	type: PowerUpType;
	price: number;
	isAvailable: boolean;
}

export enum PowerUpType {
	Rotate,
	Direction,
	FindLetter,
	FindWord
}
