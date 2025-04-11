import { writable, get, derived, type Writable, type Readable } from 'svelte/store';
import type { DailyRewardsState } from './daily-rewards.state';
// import type { DailyReward } from './daily-reward.model'; // Removed unused type import
import { DailyRewardsService } from './daily-rewards.service';

// --- Internal State Store ---
const _dailyRewardsState: Writable<DailyRewardsState | null> = writable(null); // Start as null until initialized

// --- Service Interaction ---

let refreshTimer: NodeJS.Timeout | null = null;

function setRefreshTimer(state: DailyRewardsState) {
	if (!state.resetRewardTimestamp) {
		return;
	}
	if (refreshTimer) {
		clearTimeout(refreshTimer);
	}
	const delay = state.resetRewardTimestamp - Date.now();
	refreshTimer = setTimeout(() => {
		state = DailyRewardsService._checkAndApplyResets(state);
		_dailyRewardsState.set(state);
	}, delay);
}
// Function to initialize the store by loading state via the service
async function initializeStore(): Promise<void> {
	const initialState = await DailyRewardsService.initialize();
	setRefreshTimer(initialState);
	_dailyRewardsState.set(initialState);
}

// Call initialize when the store module is loaded
// Handle potential errors during initialization
initializeStore()
	.then(() => {
		console.log('Daily Rewards Store Initialized.');
	})
	.catch((error) => {
		console.error('Failed to initialize Daily Rewards Store:', error);
	});

// --- Public Store Interface ---

// Read-only derived store for external use
export const dailyRewardsState: Readable<DailyRewardsState | null> = derived(
	_dailyRewardsState,
	($state) => $state
);

// Actions to interact with the rewards system

async function claimRewardAction(
	rewardId: string
): Promise<{ success: boolean; coinsAwarded?: number; noAdsAvailable?: boolean }> {
	const currentState = get(_dailyRewardsState);
	if (!currentState) {
		return { success: false };
	}
	try {
		const result = await DailyRewardsService.claimReward(currentState, rewardId);
		if (result?.success) {
			const newState = result.state;
			setRefreshTimer(newState);
			_dailyRewardsState.set(newState);
			return { success: true, coinsAwarded: result.coinsAwarded };
		} else if (result?.noAdsAvailable) {
			return { success: false, noAdsAvailable: true };
		}
		return { success: false };
	} catch (error) {
		return { success: false, noAdsAvailable: true };
	}
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
	// Actions:
	claimReward: claimRewardAction,
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
