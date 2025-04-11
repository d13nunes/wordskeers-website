// src/plugins/my-plugin.ts
import { registerPlugin } from '@capacitor/core';

export interface RestorePurchases {
	restore(productIds: string[]): Promise<{ productIds: string[] }>;
}

export const RestorePurchases = registerPlugin<RestorePurchases>('RestorePurchases');
