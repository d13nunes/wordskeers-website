import { writable, get, derived, type Writable, type Readable } from 'svelte/store';
import type { DailyRewardsState } from './daily-rewards.state';
// import type { DailyReward } from './daily-reward.model'; // Removed unused type import
import { DailyRewardsService } from './daily-rewards.service';
import { RESET_WINDOW_MS } from './daily-rewards.config';
import { formatDistanceStrict } from 'date-fns';

// --- Internal State Store ---
const _dailyRewardsState: Writable<DailyRewardsState | null> = writable(null); // Start as null until initialized

// --- Service Interaction ---

// Function to initialize the store by loading state via the service
async function initializeStore(): Promise<void> {
	const initialState = await DailyRewardsService.initialize();
	_dailyRewardsState.set(initialState);
}

// Function to periodically check for resets when the app might be running
// Note: This is a basic polling check. For background sync, more robust mechanisms might be needed.
// Consider using Capacitor App plugin's 'appStateChange' event instead of interval for better performance.
function startBackgroundCheck() {
	setInterval(async () => {
		const currentState = get(_dailyRewardsState);
		if (currentState) {
			// Re-run the initialization logic which includes reset checks
			// This is slightly inefficient as it reloads from storage,
			// a better approach might be to have a dedicated service method
			// that ONLY checks resets based on the *current in-memory* state.
			// For simplicity now, we re-initialize.
			await initializeStore();
		}
	}, 60 * 1000); // Check every minute
}

// Call initialize when the store module is loaded
// Handle potential errors during initialization
initializeStore()
	.then(() => {
		console.log('Daily Rewards Store Initialized.');
		// Optional: Start background checks after successful initialization
		// startBackgroundCheck();
	})
	.catch((error) => {
		console.error('Failed to initialize Daily Rewards Store:', error);
		// Handle error appropriately, maybe set a default error state?
	});

// --- Public Store Interface ---

// Read-only derived store for external use
export const dailyRewardsState: Readable<DailyRewardsState | null> = derived(
	_dailyRewardsState,
	($state) => $state
);

// Derived store for the countdown timer
export const rewardWindowCountdown: Readable<string | null> = derived(
	_dailyRewardsState,
	($state) => {
		if (
			!$state ||
			!$state.firstRewardClaimTimestamp ||
			$state.rewardsCollectedToday === 0 ||
			$state.rewardsCollectedToday >= 3
		) {
			return null; // No countdown needed
		}

		const now = Date.now();
		const endTime = $state.firstRewardClaimTimestamp + RESET_WINDOW_MS;

		if (now >= endTime) {
			return null; // Window expired
		}

		// FormatDistanceStrict provides "x minutes", "y hours" etc.
		return formatDistanceStrict(new Date(endTime), new Date(now), { addSuffix: false }); // 'in' prefix is confusing here
	}
);

// Actions to interact with the rewards system

async function claimRewardAction(
	rewardId: string
): Promise<{ success: boolean; coinsAwarded?: number }> {
	const currentState = get(_dailyRewardsState);
	if (!currentState) {
		return { success: false };
	}

	const result = await DailyRewardsService.claimReward(currentState, rewardId);
	if (result) {
		_dailyRewardsState.set(result.newState);
		return { success: true, coinsAwarded: result.coinsAwarded };
	}
	return { success: false };
}

async function claimRewardWithAdAction(
	rewardId: string
): Promise<{ success: boolean; coinsAwarded?: number }> {
	const currentState = get(_dailyRewardsState);
	if (!currentState) {
		return { success: false };
	}

	const result = await DailyRewardsService.claimRewardWithAd(currentState, rewardId);
	if (result) {
		_dailyRewardsState.set(result.newState);
		return { success: true, coinsAwarded: result.coinsAwarded };
	}
	return { success: false };
}

async function setEnableNotificationsAction(enable: boolean): Promise<void> {
	const currentState = get(_dailyRewardsState);
	if (!currentState) {
		return;
	}

	const newState = await DailyRewardsService.setEnableNotifications(currentState, enable);
	_dailyRewardsState.set(newState);
}

// Force a refresh/recheck (e.g., when app comes to foreground)
async function refreshStateAction(): Promise<void> {
	// Re-running initialize reloads and checks resets
	await initializeStore();
}

export const dailyRewardsStore = {
	subscribe: dailyRewardsState.subscribe, // Expose the main state
	countdown: rewardWindowCountdown, // Expose the derived countdown
	// Actions:
	claimReward: claimRewardAction,
	claimRewardWithAd: claimRewardWithAdAction,
	setEnableNotifications: setEnableNotificationsAction,
	refresh: refreshStateAction
};

// Example of how to listen for app state changes with Capacitor App plugin
// (You would need to install `@capacitor/app`)
/*
import { App } from '@capacitor/app';

App.addListener('appStateChange', async ({ isActive }) => {
  if (isActive) {
    console.log('App resumed, refreshing daily rewards state...');
    await dailyRewardsStore.refresh();
  }
});
*/
