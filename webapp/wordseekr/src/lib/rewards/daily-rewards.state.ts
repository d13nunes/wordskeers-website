import type { DailyReward } from './daily-reward.model';

export interface DailyRewardsState {
	currentRewards: DailyReward[];
	rewardsCollectedToday: number; // 0, 1, 2, or 3
	lastClaimTimestamp?: number; // Unix timestamp (ms)
	resetRewardTimestamp?: number; // Unix timestamp (ms) for the 4-hour window start
	notificationsEnabled: boolean;
}

export const DEFAULT_DAILY_REWARDS_STATE: DailyRewardsState = {
	currentRewards: [],
	rewardsCollectedToday: 0,
	lastClaimTimestamp: undefined,
	resetRewardTimestamp: undefined,
	notificationsEnabled: false // Start with notifications off by default
};
