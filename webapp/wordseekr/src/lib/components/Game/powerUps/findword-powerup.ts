import { PowerUpType, type PowerUp } from './powerup';
import { type Wallet } from '$lib/economy/walletStore';

export class FindLetterPowerUp implements PowerUp {
	type: PowerUpType = PowerUpType.FindLetter;
	price: number = 100;
	isAvailable: boolean = true;

	constructor(private wallet: Wallet) {}

	async use(undiscoveredWords: [Word]): Promise<boolean> {
		if (await this.wallet.canBuy(this.price)) {
			this.wallet.subtractCoins(this.price);

			return Promise.resolve(true);
		}
		return Promise.resolve(false);
	}
}
