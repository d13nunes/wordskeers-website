import { writable } from 'svelte/store';
import { Preferences } from '@capacitor/preferences';

const COIN_BALANCE_KEY = 'coinBalance';

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

async function getBalance(): Promise<number> {
	const { value } = await Preferences.get({ key: COIN_BALANCE_KEY });
	return value ? parseInt(value, 10) : 0;
}

function createWalletStore(): Wallet {
	const { subscribe, set, update } = writable<number>(0); // Initialize with 0, will be updated async

	// Load the initial balance asynchronously
	loadInitialBalance().then((initialBalance) => {
		set(initialBalance);
	});

	return {
		subscribe,
		addCoins: (amount: number) => {
			if (amount <= 0) {
				return;
			}
			update((currentBalance) => {
				const newBalance = currentBalance + amount;
				saveBalance(newBalance);
				return newBalance;
			});
		},
		subtractCoins: (amount: number) => {
			if (amount <= 0) {
				return;
			}
			update((currentBalance) => {
				const newBalance = Math.max(0, currentBalance - amount); // Prevent negative balance
				saveBalance(newBalance);
				return newBalance;
			});
		},
		// Optional: A method to reset the balance (useful for testing/debugging)
		reset: () => {
			const newBalance = 0;
			set(newBalance);
			saveBalance(newBalance);
		},
		canBuy: async (amount: number) => {
			const balance = await getBalance();
			return amount <= balance;
		}
	};
}

export interface Wallet {
	subscribe: (callback: (balance: number) => void) => void;
	canBuy: (amount: number) => Promise<boolean>;
	addCoins: (amount: number) => void;
	subtractCoins: (amount: number) => void;
	reset: () => void;
}

export const walletStore: Wallet = createWalletStore();
