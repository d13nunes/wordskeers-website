import { writable } from 'svelte/store';
import { IAPFacade } from './IAPFacade';
import type { IAPProduct, IAPTransactionEvent } from './IAPFacade';
import { walletStore } from './walletStore';
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
	REMOVE_ADS_DISCOUNT_ANDROID: 'com.wordseekr.removeads.60',
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
	PRODUCT_IDS.REMOVE_ADS_DISCOUNT_ANDROID,
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

export interface IAPProductWithLoaded extends IAPProduct {
	loaded: boolean;
}

// Store for tracking products
const createProductsStore = () => {
	const { subscribe, set } = writable<Record<string, IAPProductWithLoaded>>({});

	return {
		subscribe,
		loadProducts: async () => {
			try {
				// Get available products from stores
				const result = await IAPFacade.getProducts({
					productIds: Object.values(PRODUCT_IDS)
				});

				const products = result.products.reduce(
					(acc: Record<string, IAPProductWithLoaded>, product: IAPProduct) => ({
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
		removeAdsIds: removeAds
	};
};

function isRestoreAvailable(): Promise<boolean> {
	return IAPFacade.isRestoreAvailable();
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
	async function processOwnedProducts() {
		try {
			const ownedProducts = await IAPFacade.getOwnedProducts();
			const hasRemoveAds =
				ownedProducts.productIds.filter((productId: string) => removeAds.includes(productId))
					.length > 0;
			console.debug('hasRemoveAds ', hasRemoveAds);
			walletStore.setRemoveAds(hasRemoveAds);
		} catch (error) {
			console.error('Failed to process owned products:', error);
		}
	}

	return {
		initializePurchases: async () => {
			try {
				// Listen for transaction events
				console.log('🏪1112 initializePurchases');
				await IAPFacade.addListener('transaction', async (event: IAPTransactionEvent) => {
					try {
						console.log('🏪111 Transaction event:', event);
						if (event.type === 'success' && event.productId) {
							const productId = event.productId;

							// Handle coins purchase
							const coins = COIN_PACKS_META[productId]?.coins;
							if (coins && coins > 0) {
								walletStore.addCoins(coins);
								console.log('🏪111 Coins purchased:', coins);
								// alert(`Coins purchased: ${coins}`);
							}

							// Handle non-consumable purchases like Remove Ads
							if (removeAds.includes(productId)) {
								console.log('🏪111 Remove Ads purchased:', productId);
								walletStore.setRemoveAds(true);
								// alert('Remove Ads purchased');
							}
						} else if (event.type === 'error' && event.message) {
							alert(event.message);
						}
					} catch (error) {
						console.error('Failed to process transaction event:', error);
					}
				});

				await processOwnedProducts();
			} catch (error) {
				console.error('Failed to initialize IAP:', error);
			}
		},
		makePurchase: async (productId: string) => {
			try {
				console.log('🏪 makePurchase', productId);
				const result = await IAPFacade.purchaseProduct({
					productId,
					referenceUUID: generateReferenceUUID()
				});
				console.log('🏪 makePurchase result', JSON.stringify(result));
				if (result.transaction) {
					const transactionData = JSON.parse(result.transaction);
					console.log('🏪 makePurchase transactionData', transactionData);
					const productId = transactionData.productId;
					console.log('🏪 makePurchase productId', productId);
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
				const result = await IAPFacade.purchaseSubscription({
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
				await IAPFacade.manageSubscriptions({});
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

// Helper function to check if IAP is available
export async function isIAPAvailable(): Promise<boolean> {
	try {
		const result = await IAPFacade.getProducts({ productIds: Object.values(PRODUCT_IDS) });
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
	const isAptoide = await IAPFacade.isAptoide();
	console.debug('Loaded IAP Provider:', isAptoide ? 'Aptoide' : 'Native');
	await purchasesStore.initializePurchases();
	await productsStore.loadProducts();
}
