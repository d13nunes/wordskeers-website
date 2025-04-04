import { PowerUpType, type PowerUp } from './powerup';
import { type Wallet } from '$lib/economy/walletStore';

export class RotatePowerUp implements PowerUp {
	type: PowerUpType = PowerUpType.Rotate;
	price: number = 100;
	isAvailable: boolean = true;

	constructor(private wallet: Wallet) {}

	async use(): Promise<boolean> {
		if (await this.wallet.canBuy(this.price)) {
			this.wallet.subtractCoins(this.price);
			return Promise.resolve(true);
		}
		return Promise.resolve(false);
	}
}
