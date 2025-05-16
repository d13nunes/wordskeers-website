import { browser } from '$app/environment';

type AppStateChangeCallback = (isActive: boolean) => void;

class AppStateManager {
	private static instance: AppStateManager;
	private listeners: Set<AppStateChangeCallback> = new Set();
	private isActive: boolean = true;

	private constructor() {
		if (browser) {
			// Handle web visibility changes
			document.addEventListener('visibilitychange', () => {
				this.handleStateChange(!document.hidden);
			});

			// Handle window blur/focus for additional web support
			window.addEventListener('blur', () => {
				this.handleStateChange(false);
			});
			window.addEventListener('focus', () => {
				this.handleStateChange(true);
			});

			// Initialize Capacitor App listeners if available
			this.initializeCapacitorApp();
		}
	}

	private async initializeCapacitorApp() {
		try {
			const { App } = await import('@capacitor/app');
			App.addListener('appStateChange', ({ isActive }) => {
				this.handleStateChange(isActive);
			});
		} catch {
			// Capacitor App plugin not available, continue with web-only implementation
			console.debug('Capacitor App plugin not available, using web-only implementation');
		}
	}

	public static getInstance(): AppStateManager {
		if (!AppStateManager.instance) {
			AppStateManager.instance = new AppStateManager();
		}
		return AppStateManager.instance;
	}

	private handleStateChange(isActive: boolean) {
		if (this.isActive !== isActive) {
			this.isActive = isActive;
			this.notifyListeners();
		}
	}

	private notifyListeners() {
		this.listeners.forEach((callback) => callback(this.isActive));
	}

	public subscribe(callback: AppStateChangeCallback): () => void {
		this.listeners.add(callback);
		// Initial state notification
		callback(this.isActive);

		// Return unsubscribe function
		return () => {
			this.listeners.delete(callback);
		};
	}

	public getCurrentState(): boolean {
		return this.isActive;
	}
}

// Export a singleton instance
export const appStateManager = AppStateManager.getInstance();
