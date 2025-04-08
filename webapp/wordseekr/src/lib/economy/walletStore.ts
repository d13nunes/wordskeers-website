import { writable } from 'svelte/store';
import { Preferences } from '@capacitor/preferences';

const COIN_BALANCE_KEY = 'coinBalance';
const REMOVE_ADS_KEY = 'removeAds';

async function loadInitialBalance(): Promise<number> {
	try {
		const { value } = await Preferences.get({ key: COIN_BALANCE_KEY });
		return value ? parseInt(value, 10) : 0;
	} catch (error) {
		console.error('Failed to load coin balance from preferences:', error);
		return 0; // Default to 0 if loading fails
	}
}

async function saveBalance(balance: number): Promise<void> {
	try {
		await Preferences.set({
			key: COIN_BALANCE_KEY,
			value: balance.toString()
		});
	} catch (error) {
		console.error('Failed to save coin balance to preferences:', error);
	}
}

async function saveRemoveAds(removeAds: boolean): Promise<void> {
	try {
		await Preferences.set({
			key: REMOVE_ADS_KEY,
			value: removeAds.toString()
		});
	} catch (error) {
		console.error('Failed to save remove ads to preferences:', error);
	}
}

async function getRemoveAds(): Promise<boolean> {
	try {
		const { value } = await Preferences.get({ key: REMOVE_ADS_KEY });
		return value ? value === 'true' : false;
	} catch (error) {
		console.error('Failed to get remove ads from preferences:', error);
		return false;
	}
}

async function getBalance(): Promise<number> {
	const { value } = await Preferences.get({ key: COIN_BALANCE_KEY });
	return value ? parseInt(value, 10) : 0;
}

function createWalletStore(): Wallet {
	const { subscribe: coins, set: setCoins, update: updateCoins } = writable<number>(0); // Initialize with 0, will be updated async
	// Load the initial balance asynchronously
	loadInitialBalance().then((initialBalance) => {
		setCoins(initialBalance);
	});
	const { subscribe: removeAds, set: setRemoveAds } = writable<boolean>(false);
	getRemoveAds().then((removeAds) => {
		setRemoveAds(removeAds);
	});

	return {
		coins,
		addCoins: (amount: number) => {
			if (amount <= 0) {
				return;
			}
			updateCoins((currentBalance) => {
				const newBalance = currentBalance + amount;
				saveBalance(newBalance);
				return newBalance;
			});
		},
		subtractCoins: (amount: number) => {
			if (amount <= 0) {
				return;
			}
			updateCoins((currentBalance) => {
				const newBalance = Math.max(0, currentBalance - amount); // Prevent negative balance
				saveBalance(newBalance);
				return newBalance;
			});
		},
		removeAds,
		setRemoveAds: (removeAds: boolean) => {
			saveRemoveAds(removeAds);
			setRemoveAds(removeAds);
		},
		// Optional: A method to reset the balance (useful for testing/debugging)
		reset: () => {
			const newBalance = 0;
			setCoins(newBalance);
			saveBalance(newBalance);
			setRemoveAds(false);
			saveRemoveAds(false);
		},
		canBuy: async (amount: number) => {
			const balance = await getBalance();
			return amount <= balance;
		}
	};
}

export interface Wallet {
	coins: (callback: (balance: number) => void) => void;
	canBuy: (amount: number) => Promise<boolean>;
	addCoins: (amount: number) => void;
	subtractCoins: (amount: number) => void;
	removeAds: (callback: (removeAds: boolean) => void) => void;
	setRemoveAds: (removeAds: boolean) => void;
	reset: () => void;
}

export const walletStore: Wallet = createWalletStore();
