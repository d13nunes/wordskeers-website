import { Capacitor } from '@capacitor/core';
import { Preferences } from '@capacitor/preferences';
import { isToday } from 'date-fns'; // Using date-fns for robust date logic
import { DailyRewardsNotifications } from './daily-rewards.notifications';
import type { DailyReward } from './daily-reward.model';
import type { DailyRewardsState } from './daily-rewards.state';
import { DEFAULT_DAILY_REWARDS_STATE } from './daily-rewards.state';
import {
	DAILY_REWARDS_STORAGE_KEY,
	REWARD_COUNT,
	COIN_RANGES,
	RESET_WINDOW_MS
} from './daily-rewards.config';

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
		rewards.push({
			id: `reward-${i}-${Date.now()}`, // Simple unique ID for this set
			coins: getRandomInt(range.min, range.max),
			requiresAd: i > 0, // First reward is free
			claimed: false,
			claimable: i === 0 // Only the first reward is initially claimable
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
	let state = { ...currentState }; // Work on a copy

	// --- Daily Reset Check ---
	// If the last claim was before today, reset everything for the new day.
	if (state.lastClaimTimestamp && !isToday(new Date(state.lastClaimTimestamp))) {
		console.log('Daily reset triggered.');
		return resetRewardsState(state); // Full reset
	}

	// --- 4-Hour Window Reset Check ---
	// If the first reward was claimed, check if 4 hours have passed.
	if (state.firstRewardClaimTimestamp) {
		const fourHoursAfterFirstClaim = state.firstRewardClaimTimestamp + RESET_WINDOW_MS;
		if (now >= fourHoursAfterFirstClaim) {
			console.log('4-hour reset triggered.');
			return resetRewardsState(state); // Full reset
		}
	}

	// --- Ensure rewards exist if empty and claimable ---
	// This handles the very first launch or after a reset where state might be clean
	if (state.canClaimAnyRewardToday && state.currentRewards.length === 0) {
		console.log('Generating initial set of rewards.');
		state.currentRewards = generateNewDailyRewards();
	}

	// --- Update Claimable Status ---
	// This needs to run even if no reset happened, to update based on claims.
	state = updateClaimableStatus(state);

	return state; // Return potentially modified state
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

/**
 * Updates the `claimable` status of each reward based on the current state.
 */
function updateClaimableStatus(state: DailyRewardsState): DailyRewardsState {
	if (!state.canClaimAnyRewardToday || state.rewardsCollectedToday >= REWARD_COUNT) {
		// If no rewards can be claimed today, or all are collected, mark all as not claimable
		state.currentRewards = state.currentRewards.map((r) => ({ ...r, claimable: false }));
		return state;
	}

	let canClaimNext = true; // Start assuming the first can be claimed
	state.currentRewards = state.currentRewards.map((reward) => {
		let isClaimable = false;
		if (canClaimNext && !reward.claimed) {
			isClaimable = true;
			canClaimNext = false; // Only one can be claimable at a time
		}
		return { ...reward, claimable: isClaimable };
	});

	return state;
}

/**
 * Marks a reward as claimed and updates the state.
 * Assumes the reward IS claimable. Validation should happen before calling.
 * Returns the updated state and the number of coins awarded.
 */
function claimRewardAndUpdateState(
	currentState: DailyRewardsState,
	rewardId: string
): { newState: DailyRewardsState; coinsAwarded: number } | null {
	const rewardIndex = currentState.currentRewards.findIndex((r) => r.id === rewardId);
	const reward = currentState.currentRewards[rewardIndex];

	if (rewardIndex === -1 || !reward || reward.claimed || !reward.claimable) {
		console.error('Attempted to claim invalid or already claimed/unclaimable reward:', rewardId);
		return null; // Reward not found or cannot be claimed
	}

	let state = { ...currentState }; // Work on a copy
	const now = Date.now();

	// Mark as claimed
	state.currentRewards = state.currentRewards.map((r, index) =>
		index === rewardIndex ? { ...r, claimed: true, claimable: false } : r
	);

	state.rewardsCollectedToday += 1;
	state.lastClaimTimestamp = now;

	// If this is the first reward claimed in this cycle, set the 4-hour timer start
	if (state.rewardsCollectedToday === 1) {
		state.firstRewardClaimTimestamp = now;
	}

	// Check if all rewards for today are now collected
	if (state.rewardsCollectedToday >= REWARD_COUNT) {
		state.canClaimAnyRewardToday = false;
	}

	// Update claimable status for the *next* reward
	state = updateClaimableStatus(state);

	// Schedule notification if enabled
	if (state.notificationsEnabled) {
		DailyRewardsNotifications.scheduleNextRewardNotification(
			state.firstRewardClaimTimestamp,
			state.lastClaimTimestamp
		);
	}

	return { newState: state, coinsAwarded: reward.coins };
}

// --- Exposed Service Methods ---

async function initialize(): Promise<DailyRewardsState> {
	let state = await loadState();
	state = checkAndApplyResets(state); // Apply resets based on loaded time data
	await saveState(state); // Save potentially reset state
	// Initial notification setup check (permissions, schedule if needed)
	if (state.notificationsEnabled) {
		await DailyRewardsNotifications.initializeNotifications();
		await DailyRewardsNotifications.scheduleNextRewardNotification(
			state.firstRewardClaimTimestamp,
			state.lastClaimTimestamp
		);
	}
	return state;
}

async function claimReward(
	currentState: DailyRewardsState,
	rewardId: string
): Promise<{ newState: DailyRewardsState; coinsAwarded: number } | null> {
	// Basic validation (can add more specific checks if needed)
	const reward = currentState.currentRewards.find((r) => r.id === rewardId);
	if (!reward || reward.claimed || !reward.claimable || reward.requiresAd) {
		console.warn('Cannot claim reward (free). Invalid state or requires ad.', rewardId);
		return null;
	}

	const result = claimRewardAndUpdateState(currentState, rewardId);
	if (result) {
		await saveState(result.newState);
		return result;
	}
	return null;
}

// Placeholder for ad logic - replace with actual Ad interaction
async function showRewardAd(): Promise<boolean> {
	console.log('Showing reward ad...');
	// TODO: Integrate with your ad provider (e.g., AdMob via Capacitor plugin)
	// Return true if the ad was watched successfully, false otherwise.
	await new Promise((resolve) => setTimeout(resolve, 1500)); // Simulate ad watch time
	console.log('Ad watched successfully (simulated).');
	return true;
}

async function claimRewardWithAd(
	currentState: DailyRewardsState,
	rewardId: string
): Promise<{ newState: DailyRewardsState; coinsAwarded: number } | null> {
	const reward = currentState.currentRewards.find((r) => r.id === rewardId);
	if (!reward || reward.claimed || !reward.claimable || !reward.requiresAd) {
		console.warn('Cannot claim reward (ad). Invalid state or does not require ad.', rewardId);
		return null;
	}

	const adWatched = await showRewardAd(); // Show the ad first
	if (!adWatched) {
		console.log('Ad not watched, reward not claimed.');
		return null;
	}

	// Ad watched, proceed to claim
	const result = claimRewardAndUpdateState(currentState, rewardId);
	if (result) {
		await saveState(result.newState);
		return result;
	}
	return null;
}

async function setEnableNotifications(
	currentState: DailyRewardsState,
	enable: boolean
): Promise<DailyRewardsState> {
	let state = { ...currentState, notificationsEnabled: enable };
	if (enable) {
		const permissionGranted = await DailyRewardsNotifications.requestPermissions();
		if (permissionGranted) {
			await DailyRewardsNotifications.initializeNotifications(); // Ensure channel exists etc.
			await DailyRewardsNotifications.scheduleNextRewardNotification(
				state.firstRewardClaimTimestamp,
				state.lastClaimTimestamp
			);
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
	claimRewardWithAd,
	setEnableNotifications
	// Expose internal helpers only if needed externally (generally avoid)
	// _checkAndApplyResets: checkAndApplyResets, // Example if needed for debugging/testing
	// _generateNewDailyRewards: generateNewDailyRewards, // Example
};
