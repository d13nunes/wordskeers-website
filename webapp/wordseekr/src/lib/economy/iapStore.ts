import { writable, derived } from 'svelte/store';
import { CapacitorInAppPurchase } from '@adplorg/capacitor-in-app-purchase';
import type { Product, TransactionEvent } from '@adplorg/capacitor-in-app-purchase';
import { walletStore } from './walletStore';
import { Capacitor } from '@capacitor/core';
import { RestorePurchases } from '$lib/plugins/RestorePurchases';

// Product IDs as they appear in App Store/Google Play
export const PRODUCT_IDS = {
	COIN_PACK_SMALL: 'com.wordseekr.coinpack.100',
	COIN_PACK_MEDIUM: 'com.wordseekr.coinpack.300',
	COIN_PACK_LARGE: 'com.wordseekr.coinpack.700',
	COIN_PACK_HUGE: 'com.wordseekr.coinpack.1500',
	REMOVE_ADS_OLD: 'com.wordseekr.coinpack.removeads',
	REMOVE_ADS_DISCOUNT_OLD: 'com.wordseekr.coinpack.removeads60',
	REMOVE_ADS: 'com.wordseekr.removeads',
	REMOVE_ADS_DISCOUNT: 'com.wordseekr.removeads60'
};

interface ProductMeta {
	coins: number;
	title: string;
	description: string;
	callout?: string;
	isCalloutRed?: boolean;
}

export const removeAds = [
	PRODUCT_IDS.REMOVE_ADS,
	PRODUCT_IDS.REMOVE_ADS_DISCOUNT,
	PRODUCT_IDS.REMOVE_ADS_OLD,
	PRODUCT_IDS.REMOVE_ADS_DISCOUNT_OLD
];
// Map product IDs to coin amounts
export const COIN_PACKS_META: Record<string, ProductMeta> = {
	[PRODUCT_IDS.COIN_PACK_SMALL]: {
		coins: 300,
		title: 'Starter Pack',
		description: '300 coins'
	},
	[PRODUCT_IDS.COIN_PACK_MEDIUM]: {
		coins: 900,
		title: 'Popular Pack',
		description: '900 coins'
	},
	[PRODUCT_IDS.COIN_PACK_LARGE]: {
		coins: 2000,
		title: 'Premium Pack',
		description: '2000 coins',
		callout: 'Most Popular',
		isCalloutRed: true
	},
	[PRODUCT_IDS.COIN_PACK_HUGE]: {
		coins: 4000,
		title: 'Mega Pack',
		description: '4000 coins',
		callout: 'Best Value',
		isCalloutRed: false
	},
	[PRODUCT_IDS.REMOVE_ADS]: {
		coins: 0,
		title: 'Ad-Free Experience',
		description: 'Remove all ads permanently'
	},
	[PRODUCT_IDS.REMOVE_ADS_DISCOUNT]: {
		coins: 0,
		title: 'Ad-Free Experience',
		description: 'Remove all ads permanently'
	}
};

// Generate a unique reference UUID for transactions
function generateReferenceUUID(): string {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
		const r = (Math.random() * 16) | 0;
		const v = c === 'x' ? r : (r & 0x3) | 0x8;
		return v.toString(16);
	});
}

export interface IAPProduct extends Product {
	loaded: boolean;
}

// Store for tracking products
const createProductsStore = () => {
	const { subscribe, set } = writable<Record<string, IAPProduct>>({});

	return {
		subscribe,
		loadProducts: async () => {
			try {
				// Get available products from stores
				const result = await CapacitorInAppPurchase.getProducts({
					productIds: Object.values(PRODUCT_IDS)
				});

				const products = result.products.reduce(
					(acc: Record<string, IAPProduct>, product: Product) => ({
						...acc,
						[product.id]: {
							...product,
							loaded: true
						}
					}),
					{}
				);
				set(products);
				return products;
			} catch (error) {
				console.error('Failed to load IAP products:', error);
				return {};
			}
		},
		removeAdsIds: PRODUCT_IDS.REMOVE_ADS_DISCOUNT
	};
};

function isRestoreAvailable() {
	try {
		const isAvailable = Capacitor.isPluginAvailable('RestorePurchases');
		return isAvailable;
	} catch (error) {
		console.error('Failed to check restore availability: isRestoreAvailable', error);
		return false;
	}
}

async function restorePurchases(): Promise<boolean> {
	try {
		const result = await RestorePurchases.restore(removeAds);
		const isSuccess = result.productIds.length > 0;
		if (isSuccess) {
			walletStore.setRemoveAds(true);
		}
		return isSuccess;
	} catch (error) {
		console.error('Failed to restore purchases:', error);
		return false;
	}
}
// Store for tracking purchases
const createPurchasesStore = () => {
	const { subscribe, update } = writable<Record<string, boolean>>({
		[PRODUCT_IDS.REMOVE_ADS]: false
	});

	return {
		subscribe,
		initializePurchases: async () => {
			try {
				// Listen for transaction events
				await CapacitorInAppPurchase.addListener('transaction', async (event: TransactionEvent) => {
					console.log('Transaction event:', event);

					if (event.type === 'success' && event.transaction) {
						const transactionData = JSON.parse(event.transaction);
						const productId = transactionData.productId;

						// Handle coins purchase
						if (COIN_PACKS_META[productId]) {
							walletStore.addCoins(COIN_PACKS_META[productId].coins);
						}

						// Handle non-consumable purchases like Remove Ads
						if (removeAds.includes(productId)) {
							walletStore.setRemoveAds(true);
						}
					}
				});

				// Check for existing purchases (like remove ads)
				const activeSubscriptions = await CapacitorInAppPurchase.getActiveSubscriptions();
				if (activeSubscriptions.subscriptions.includes(PRODUCT_IDS.REMOVE_ADS)) {
					update((state) => ({ ...state, [PRODUCT_IDS.REMOVE_ADS]: true }));
				}
			} catch (error) {
				console.error('Failed to initialize IAP:', error);
			}
		},
		makePurchase: async (productId: string) => {
			try {
				const result = await CapacitorInAppPurchase.purchaseProduct({
					productId,
					referenceUUID: generateReferenceUUID()
				});
				if (result.transaction) {
					const transactionData = JSON.parse(result.transaction);
					const productId = transactionData.productId;
					if (removeAds.includes(productId)) {
						walletStore.setRemoveAds(true);
					}
				}
				return result;
			} catch (error) {
				console.error('Purchase failed:', error);
				throw error;
			}
		},
		purchaseSubscription: async (productId: string) => {
			try {
				const result = await CapacitorInAppPurchase.purchaseSubscription({
					productId,
					referenceUUID: generateReferenceUUID()
				});
				return result;
			} catch (error) {
				console.error('Subscription purchase failed:', error);
				throw error;
			}
		},
		manageSubscriptions: async () => {
			try {
				await CapacitorInAppPurchase.manageSubscriptions({});
			} catch (error) {
				console.error('Failed to open subscription management:', error);
				throw error;
			}
		},
		isRestoreAvailable,
		restore: restorePurchases
	};
};

// Create stores
export const productsStore = createProductsStore();
export const purchasesStore = createPurchasesStore();

// Derived store for checking if ads are removed
export const adsRemoved = derived(
	purchasesStore,
	($purchasesStore) => $purchasesStore[PRODUCT_IDS.REMOVE_ADS] || false
);

// Helper function to check if IAP is available
export async function isIAPAvailable(): Promise<boolean> {
	try {
		const result = await CapacitorInAppPurchase.getProducts({
			productIds: [PRODUCT_IDS.COIN_PACK_SMALL] // Just check with one product
		});
		console.log('result', result);
		return result.products.length > 0;
	} catch (error) {
		console.warn('IAP is not available in this environment:', error);
		return false;
	}
}

// Helper function to initialize the IAP system
export async function initializeIAP() {
	const isAvailable = await isIAPAvailable();
	if (!isAvailable) {
		console.warn('IAP initialization skipped - not available in this environment');
		return;
	}

	await purchasesStore.initializePurchases();
	await productsStore.loadProducts();
}
