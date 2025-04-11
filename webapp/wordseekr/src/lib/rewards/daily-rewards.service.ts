import { Capacitor } from '@capacitor/core';
import { Preferences } from '@capacitor/preferences';
import { DailyRewardsNotifications } from './daily-rewards.notifications';
import { DailyRewardStatus, type DailyReward } from './daily-reward.model';
import { type DailyRewardsState, DEFAULT_DAILY_REWARDS_STATE } from './daily-rewards.state';
import {
	DAILY_REWARDS_STORAGE_KEY,
	REWARD_COUNT,
	COIN_RANGES,
	RESET_WINDOW_MS
} from './daily-rewards.config';
import { adStore } from '$lib/ads/ads';
import { AdType } from '$lib/ads/ads-types';
import { walletStore } from '$lib/economy/walletStore';

// Helper to get random int in range (inclusive)
function getRandomInt(min: number, max: number): number {
	min = Math.ceil(min);
	max = Math.floor(max);
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

// --- State Persistence ---

async function saveState(state: DailyRewardsState): Promise<void> {
	if (!Capacitor.isPluginAvailable('Preferences')) {
		console.warn('Preferences plugin not available, state not saved.');
		return; // Optionally fallback to localStorage for web
	}
	try {
		await Preferences.set({
			key: DAILY_REWARDS_STORAGE_KEY,
			value: JSON.stringify(state)
		});
	} catch (error) {
		console.error('Failed to save daily rewards state:', error);
	}
}

async function loadState(): Promise<DailyRewardsState> {
	if (!Capacitor.isPluginAvailable('Preferences')) {
		console.warn('Preferences plugin not available, returning default state.');
		// Optionally try localStorage for web?
		return { ...DEFAULT_DAILY_REWARDS_STATE };
	}
	try {
		const { value } = await Preferences.get({ key: DAILY_REWARDS_STORAGE_KEY });
		if (value) {
			const parsedState = JSON.parse(value) as DailyRewardsState;
			// Basic validation if needed
			if (parsedState && Array.isArray(parsedState.currentRewards)) {
				// Merge with default state to ensure all keys exist if structure changed
				return { ...DEFAULT_DAILY_REWARDS_STATE, ...parsedState };
			}
		}
	} catch (error) {
		console.error('Failed to load daily rewards state:', error);
	}
	return { ...DEFAULT_DAILY_REWARDS_STATE }; // Return default state on failure or no data
}

// --- Core Logic ---

function generateNewDailyRewards(): DailyReward[] {
	const rewards: DailyReward[] = [];
	for (let i = 0; i < REWARD_COUNT; i++) {
		const range = COIN_RANGES[i] ?? COIN_RANGES[COIN_RANGES.length - 1]; // Fallback to last range
		const isFirstReward = i === 0;
		rewards.push({
			id: `reward-${i}-${Date.now()}`, // Simple unique ID for this set
			coins: getRandomInt(range.min, range.max),
			requiresAd: !isFirstReward, // First reward is free
			status: isFirstReward ? DailyRewardStatus.Claimable : DailyRewardStatus.Locked
		});
	}
	return rewards;
}

/**
 * Checks if the daily rewards need to be reset based on time.
 * This should be called when the app loads or becomes active.
 */
function checkAndApplyResets(currentState: DailyRewardsState): DailyRewardsState {
	const now = Date.now();
	// --- 4-Hour Window Reset Check ---
	// If the first reward was claimed, check if 4 hours have passed.
	if (currentState.resetRewardTimestamp) {
		const fourHoursAfterFirstClaim = currentState.resetRewardTimestamp;

		if (now >= fourHoursAfterFirstClaim) {
			return resetRewardsState(currentState); // Full reset
		}
	}
	if (currentState.currentRewards.length === 0) {
		currentState.currentRewards = generateNewDailyRewards();
	}

	// --- Ensure rewards exist if empty and claimable ---
	// This handles the very first launch or after a reset where state might be clean
	const canClaimAnyReward =
		currentState.currentRewards.filter((r) => r.status === DailyRewardStatus.Claimable).length > 0;
	if (canClaimAnyReward && currentState.currentRewards.length === 0) {
		currentState.currentRewards = generateNewDailyRewards();
	}

	return currentState; // Return potentially modified state
}

/**
 * Resets the reward state completely for a new cycle.
 */
function resetRewardsState(currentState: DailyRewardsState): DailyRewardsState {
	return {
		...DEFAULT_DAILY_REWARDS_STATE, // Start from defaults
		currentRewards: generateNewDailyRewards(), // Generate new rewards
		// Preserve notification preference across resets
		notificationsEnabled: currentState.notificationsEnabled
	};
}

// --- Exposed Service Methods ---

async function initialize(): Promise<DailyRewardsState> {
	let state = await loadState();
	state = checkAndApplyResets(state); // Apply resets based on loaded time data
	await saveState(state); // Save potentially reset state
	// Initial notification setup check (permissions, schedule if needed)
	return state;
}

async function scheduleNotifications(state: DailyRewardsState): Promise<void> {
	if (state.notificationsEnabled) {
		await DailyRewardsNotifications.initializeNotifications();
		if (state.resetRewardTimestamp) {
			await DailyRewardsNotifications.scheduleNextRewardNotification(state.resetRewardTimestamp);
		}
	}
}

async function claimReward(
	state: DailyRewardsState,
	rewardId: string
): Promise<{
	state: DailyRewardsState;
	success: boolean;
	coinsAwarded?: number;
	noAdsAvailable?: boolean;
} | null> {
	// Basic validation (can add more specific checks if needed)
	const reward = state.currentRewards.find((r) => r.id === rewardId);
	if (!reward || reward.status !== DailyRewardStatus.Claimable) {
		console.warn('Cannot claim reward. Not claimable.', rewardId);
		return null;
	}

	let canReward = false;

	if (reward.requiresAd) {
		const isAdLoaded = await adStore.isAdLoaded(AdType.Rewarded);
		if (!isAdLoaded) {
			return { state, success: false, noAdsAvailable: true };
		}
		const didWatchAd = await adStore.showAd(AdType.Rewarded);
		if (!didWatchAd) {
			return { state, success: false };
		}
		canReward = true;
	} else {
		state.resetRewardTimestamp = Date.now() + RESET_WINDOW_MS;
		await scheduleNotifications(state);
		canReward = true;
	}

	if (!canReward) {
		return { state, success: false };
	}

	const nextClaimableReward = state.currentRewards
		.sort((a, b) => a.coins - b.coins)
		.find((r) => r.status === DailyRewardStatus.Locked);

	state.currentRewards = state.currentRewards.map((r) => {
		if (r.id === rewardId) {
			r.status = DailyRewardStatus.Claimed;
		}
		if (r.id === nextClaimableReward?.id) {
			r.status = DailyRewardStatus.Claimable;
		}
		return r;
	});

	walletStore.addCoins(reward.coins);
	state.rewardsCollectedToday += 1;

	await saveState(state);
	return { state, success: true, coinsAwarded: reward.coins };
}

async function setEnableNotifications(
	currentState: DailyRewardsState,
	enable: boolean
): Promise<DailyRewardsState> {
	let state = { ...currentState, notificationsEnabled: enable };
	if (enable) {
		const permissionGranted = await DailyRewardsNotifications.requestPermissions();
		if (permissionGranted) {
			await scheduleNotifications(state);
		} else {
			console.warn('Notification permissions denied.');
			state = { ...state, notificationsEnabled: false }; // Revert if permissions denied
		}
	} else {
		await DailyRewardsNotifications.cancelScheduledNotifications();
	}
	await saveState(state);
	return state;
}

export const DailyRewardsService = {
	initialize,
	claimReward,
	setEnableNotifications,
	// Expose internal helpers for testing
	_checkAndApplyResets: checkAndApplyResets
};
