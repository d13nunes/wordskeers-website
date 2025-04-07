import { initializeIAP } from '$lib/economy/iapStore';
import { browser } from '$app/environment';

// Initialize IAP on client-side startup
if (browser) {
	// Initialize IAP on a slight delay to ensure the app is fully loaded
	setTimeout(() => {
		initializeIAP().catch((error) => {
			console.error('Failed to initialize IAP:', error);
		});
	}, 1000);
}
