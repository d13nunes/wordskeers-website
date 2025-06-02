import { writable } from 'svelte/store';
import { myLocalStorage } from '$lib/storage/local-storage';

async function loadInitialBalance(): Promise<number> {
	try {
		const balance = await myLocalStorage.get(myLocalStorage.CoinBalance);
		return balance ? parseInt(balance, 10) : 0;
	} catch (error) {
		console.error('Failed to load coin balance from preferences:', error);
		return 0; // Default to 0 if loading fails
	}
}

async function saveBalance(balance: number): Promise<void> {
	try {
		await myLocalStorage.set(myLocalStorage.CoinBalance, balance.toString());
	} catch (error) {
		console.error('Failed to save coin balance to preferences:', error);
	}
}

async function saveRemoveAds(removeAds: boolean): Promise<void> {
	try {
		await myLocalStorage.set(myLocalStorage.RemoveAds, removeAds.toString());
	} catch (error) {
		console.error('Failed to save remove ads to preferences:', error);
	}
}

async function getRemoveAds(): Promise<boolean> {
	try {
		const removeAds = await myLocalStorage.get(myLocalStorage.RemoveAds);
		return removeAds ? removeAds === 'true' : false;
	} catch (error) {
		console.error('Failed to get remove ads from preferences:', error);
		return false;
	}
}

async function getBalance(): Promise<number> {
	const balance = await myLocalStorage.get(myLocalStorage.CoinBalance);
	return balance ? parseInt(balance, 10) : 0;
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

	async function canBuy(amount: number): Promise<boolean> {
		const balance = await getBalance();
		return amount <= balance;
	}

	async function addCoins(amount: number): Promise<void> {
		return new Promise((resolve) => {
			updateCoins((currentBalance) => {
				const newBalance = Math.max(0, currentBalance + amount); // Ensure balance is not negative
				saveBalance(newBalance);
				return newBalance;
			});
			resolve();
		});
	}

	return {
		coins,
		addCoins: (amount: number) => {
			if (amount <= 0) {
				return;
			}
			addCoins(amount);
		},
		canBuy,
		tryAndBuy: async (amount: number) => {
			if (amount <= 0) {
				return false;
			}
			if (!(await canBuy(amount))) {
				return false;
			}
			await addCoins(-amount);
			return true;
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
		}
	};
}

export interface Wallet {
	coins: (callback: (balance: number) => void) => void;
	addCoins: (amount: number) => void;
	canBuy: (amount: number) => Promise<boolean>;
	tryAndBuy: (amount: number) => Promise<boolean>;
	removeAds: (callback: (removeAds: boolean) => void) => void;
	setRemoveAds: (removeAds: boolean) => void;
	reset: () => void;
}

export const walletStore: Wallet = createWalletStore();
