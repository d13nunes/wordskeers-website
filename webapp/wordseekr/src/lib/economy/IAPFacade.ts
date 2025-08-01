// Facade for In-App Purchase SDK selection
// import { Capacitor } from '@capacitor/core';

// Import both SDKs (replace with actual import for Aptoide if available)
import { CapacitorInAppPurchase } from '@adplorg/capacitor-in-app-purchase';
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
	transaction?: string;
	message?: string;
	// Add any Aptoide-specific fields here as optional
}

let isAptoideAvailable: boolean | null = null;
async function isAptoide() {
	if (isAptoideAvailable === null) {
		isAptoideAvailable = (await AppCoinsSdk.isAvailable()).isAvailable;
	}
	return isAptoideAvailable;
}

// Facade methods (mimic the interface used in iapStore.ts, but only use unified types)
export const IAPFacade = {
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
					displayPrice: p.label,
					priceInMicros: 0, // Aptoide does not provide, set to 0 or parse if possible
					currencyCode: p.currency
				}));
			return { products };
		} else {
			// adplorg
			const result = await CapacitorInAppPurchase.getProducts(args);
			const products: IAPProduct[] = result.products.map((p: IAPProduct) => ({ ...p }));
			return { products };
		}
	},
	purchaseProduct: async (args: {
		productId: string;
		referenceUUID: string;
	}): Promise<{ transaction: string }> => {
		if (await isAptoide()) {
			// Aptoide: purchase({ sku })
			const result = await AppCoinsSdk.purchase({ sku: args.productId });
			return { transaction: JSON.stringify(result) };
		} else {
			// adplorg
			return CapacitorInAppPurchase.purchaseProduct(args);
		}
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
			// Aptoide: no event system, so simulate with polling or not supported
			// For now, do nothing and warn
			console.warn('Aptoide SDK does not support transaction events.');
			return { remove: async () => {} };
		} else {
			return CapacitorInAppPurchase.addListener(event, callback);
		}
	}
};
