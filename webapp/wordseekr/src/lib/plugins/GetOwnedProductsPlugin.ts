import { registerPlugin } from '@capacitor/core';

export interface GetOwnedProductsPlugin {
	getOwnedProducts(): Promise<{ productIds: string[] }>;
}

export const GetOwnedProductsPlugin =
	registerPlugin<GetOwnedProductsPlugin>('GetOwnedProductsPlugin');
