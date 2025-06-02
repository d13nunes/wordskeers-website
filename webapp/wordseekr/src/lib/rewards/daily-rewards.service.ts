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
import { analytics } from '$lib/analytics/analytics';

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
				// Convert resetRewardDate string back to Date object if it exists
				if (parsedState.resetRewardDate) {
					parsedState.resetRewardDate = new Date(parsedState.resetRewardDate);
				}
				if (parsedState.lastClaimDate) {
					parsedState.lastClaimDate = new Date(parsedState.lastClaimDate);
				}
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
	try {
		// --- 4-Hour Window Reset Check ---
		// If the first reward was claimed, check if 4 hours have passed.
		if (currentState.resetRewardDate) {
			const fourHoursAfterFirstClaim = currentState.resetRewardDate;
			console.log('📨📨 error checkAndApplyResets resetRewardDate', fourHoursAfterFirstClaim);

			if (Date.now() >= fourHoursAfterFirstClaim.getTime()) {
				return resetRewardsState(currentState); // Full reset
			}
		}
		if (currentState.currentRewards.length === 0) {
			currentState.currentRewards = generateNewDailyRewards();
		}

		// --- Ensure rewards exist if empty and claimable ---
		// This handles the very first launch or after a reset where state might be clean
		const canClaimAnyReward =
			currentState.currentRewards.filter((r) => r.status === DailyRewardStatus.Claimable).length >
			0;
		if (canClaimAnyReward && currentState.currentRewards.length === 0) {
			currentState.currentRewards = generateNewDailyRewards();
		}

		return currentState; // Return potentially modified state
	} catch (error) {
		console.error('Failed to check and apply resets:', error);
		return DEFAULT_DAILY_REWARDS_STATE;
	}
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
	console.log('📨📨 error initialize state', state.currentRewards);
	state = checkAndApplyResets(state); // Apply resets based on loaded time data
	console.log('📨📨 error initialize state after checkAndApplyResets', state);
	await saveState(state); // Save potentially reset state
	// Initial notification setup check (permissions, schedule if needed)
	return state;
}

async function scheduleNotifications(state: DailyRewardsState): Promise<void> {
	console.log('📨 !!!!!! Scheduling notifications... enabled:', state.notificationsEnabled);
	if (state.notificationsEnabled) {
		await DailyRewardsNotifications.initializeNotifications();
		if (state.resetRewardDate) {
			console.log('📨Scheduling next reward notification... fcfcfc', state.resetRewardDate);
			const lastRewardCollectionDate = new Date(state.resetRewardDate);

			console.log('📨Scheduling next reward notification..1.', lastRewardCollectionDate);
			await DailyRewardsNotifications.scheduleNextRewardNotification(lastRewardCollectionDate);
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
		const didWatchAd = await adStore.showAd(AdType.Rewarded, null);
		if (!didWatchAd) {
			return { state, success: false };
		}
		analytics.rewardCollectedAd();
		canReward = true;
	} else {
		state.resetRewardDate = new Date(Date.now() + RESET_WINDOW_MS);
		await scheduleNotifications(state);
		canReward = true;
		analytics.rewardCollected();
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
