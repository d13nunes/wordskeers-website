// Facade for In-App Purchase SDK selection
// import { Capacitor } from '@capacitor/core';

// Import both SDKs (replace with actual import for Aptoide if available)
import { GetOwnedProductsPlugin } from '$lib/plugins/GetOwnedProductsPlugin';
import { CapacitorInAppPurchase } from '@adplorg/capacitor-in-app-purchase';
import { Capacitor } from '@capacitor/core';
// Placeholder import for Aptoide SDK
// Replace with the actual import path for your Aptoide plugin
// import { AppCoinsSdk } from '@aptoide/appcoins-capacitor-plugin';
import { AppCoinsSdk } from 'aptoide-appcoinssdk';

// Unified types for IAP
export interface IAPProduct {
	id: string;
	type: string;
	displayName: string;
	description: string;
	displayPrice: string;
	priceInMicros: number;
	currencyCode: string;
	// Optional fields for subscriptions, etc.
	isSubscriptionGroupEntitled?: boolean;
	subscriptionPeriod?: {
		numberOfUnits: number;
		unit: string;
	};
	subscriptionGroup?: {
		id: string;
		displayName: string;
	};
	basePlans?: {
		id: string;
		offerToken: string;
		displayPrice: string;
		priceInMicros: number;
		currencyCode: string;
		subscriptionPeriod: {
			numberOfUnits: number;
			unit: string;
		};
	}[];
	// Add any Aptoide-specific fields here as optional
}

export interface IAPTransactionEvent {
	type: 'success' | 'error';
	productId?: string;
	message?: string;
	// Add any Aptoide-specific fields here as optional
}

let isAptoideAvailable: boolean | null = null;
async function isAptoide() {
	if (isAptoideAvailable === null) {
		try {
			const result = await AppCoinsSdk.isAvailable();
			isAptoideAvailable = result.isAvailable;
		} catch (error) {
			console.error('Error checking Aptoide availability:', error);
			isAptoideAvailable = false;
		}
	}
	return isAptoideAvailable;
}

// Facade methods (mimic the interface used in iapStore.ts, but only use unified types)
export const IAPFacade = {
	isAptoide,
	getProducts: async (args: { productIds: string[] }): Promise<{ products: IAPProduct[] }> => {
		if (await isAptoide()) {
			// Aptoide: get all products, filter by productIds
			const result = await AppCoinsSdk.getProducts();
			const products: IAPProduct[] = result.products
				.filter((p) => args.productIds.includes(p.sku))
				.map((p) => ({
					id: p.sku,
					type: 'iap',
					displayName: p.title,
					description: p.description,
					displayPrice: p.price,
					priceInMicros: 0,
					currencyCode: p.currency + ' ' + p.price
				}));
			return { products };
		} else {
			// adplorg
			const result = await CapacitorInAppPurchase.getProducts(args);
			const products: IAPProduct[] = result.products.map((p: IAPProduct) => ({ ...p }));
			return { products };
		}
	},
	_purchaseProduct: async (args: {
		productId: string;
		referenceUUID: string;
	}): Promise<{ transaction: string }> => {
		try {
			if (await isAptoide()) {
				const result = await AppCoinsSdk.purchase({ sku: args.productId });
				return {
					transaction: JSON.stringify({
						...result,
						productId: result.sku
					})
				};
			} else {
				// adplorg
				return CapacitorInAppPurchase.purchaseProduct(args);
			}
		} catch (error) {
			console.error('Purchase failed:', error);
			throw error;
		}
	},
	get purchaseProduct() {
		return this._purchaseProduct;
	},
	set purchaseProduct(value) {
		this._purchaseProduct = value;
	},
	purchaseSubscription: async (args: {
		productId: string;
		referenceUUID: string;
	}): Promise<{ transaction: string }> => {
		if (await isAptoide()) {
			// Aptoide does not support subscriptions, throw or fallback
			throw new Error('Subscriptions not supported on Aptoide');
		} else {
			return CapacitorInAppPurchase.purchaseSubscription(args);
		}
	},
	manageSubscriptions: async (args: object): Promise<void> => {
		if (await isAptoide()) {
			// Not supported on Aptoide
			throw new Error('Manage subscriptions not supported on Aptoide');
		} else {
			return CapacitorInAppPurchase.manageSubscriptions(args);
		}
	},
	addListener: async (event: 'transaction', callback: (event: IAPTransactionEvent) => void) => {
		if (await isAptoide()) {
			AppCoinsSdk.addListener(event, (event) => {
				callback({
					type: event.type,
					productId: event.sku,
					message: event.message
				});
			});
		} else {
			return CapacitorInAppPurchase.addListener(event, (event) => {
				let productId = undefined;
				if (event.transaction) {
					const transaction = JSON.parse(event.transaction);
					productId = transaction.productId;
				}
				callback({
					type: event.type,
					productId: productId,
					message: event.message
				});
			});
		}
	},
	isRestoreAvailable: async (): Promise<boolean> => {
		try {
			isAptoideAvailable = await isAptoide();
			if (isAptoideAvailable) {
				return false;
			}
			const isAvailable = Capacitor.isPluginAvailable('RestorePurchases');
			return isAvailable;
		} catch (error) {
			console.error('Failed to check restore availability: isRestoreAvailable', error);
			return false;
		}
		return true;
	},
	restorePurchases: async () => {
		return true;
	},
	getOwnedProducts: async (): Promise<{ productIds: string[] }> => {
		if (await isAptoide()) {
			const ownedProducts = await AppCoinsSdk.getPurchases();
			return { productIds: ownedProducts.purchases.map((p) => p.sku) };
		} else {
			const ownedProducts = await GetOwnedProductsPlugin.getOwnedProducts();
			return { productIds: ownedProducts.productIds };
		}
	}
};
