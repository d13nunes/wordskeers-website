import { writable, derived } from 'svelte/store';
import { CapacitorInAppPurchase } from '@adplorg/capacitor-in-app-purchase';
import type { Product, TransactionEvent } from '@adplorg/capacitor-in-app-purchase';
import { walletStore } from './walletStore';

// Product IDs as they appear in App Store/Google Play
export const PRODUCT_IDS = {
	COIN_PACK_SMALL: 'com.wordseekr.coinpack.100',
	COIN_PACK_MEDIUM: 'com.wordseekr.coinpack.300',
	COIN_PACK_LARGE: 'com.wordseekr.coinpack.700',
	COIN_PACK_HUGE: 'com.wordseekr.coinpack.1500',
	REMOVE_ADS: 'com.wordseekr.coinpack.removeads',
	REMOVE_ADS_DISCOUNT: 'com.wordseekr.coinpack.removeads60'
};

interface ProductMeta {
	coins: number;
	title: string;
	description: string;
}

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
		description: '2000 coins'
	},
	[PRODUCT_IDS.COIN_PACK_HUGE]: {
		coins: 4000,
		title: 'Mega Pack',
		description: '4000 coins'
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
		}
	};
};

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
						if (productId === PRODUCT_IDS.REMOVE_ADS) {
							update((state) => ({ ...state, [productId]: true }));
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
		}
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

// Helper function to initialize the IAP system
export async function initializeIAP() {
	await purchasesStore.initializePurchases();
	await productsStore.loadProducts();
}
