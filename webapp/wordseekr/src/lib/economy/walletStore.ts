import { writable } from 'svelte/store';
import { Preferences } from '@capacitor/preferences';

const COIN_BALANCE_KEY = 'coinBalance';

async function loadInitialBalance(): Promise<number> {
	try {
		const { value } = await Preferences.get({ key: COIN_BALANCE_KEY });
		console.log('!! value', value);
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

function createWalletStore() {
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
		}
	};
}

export const walletStore = createWalletStore();
