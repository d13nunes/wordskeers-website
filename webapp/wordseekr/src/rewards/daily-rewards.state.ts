import type { DailyReward } from './daily-reward.model';

export interface DailyRewardsState {
	currentRewards: DailyReward[];
	rewardsCollectedToday: number; // 0, 1, 2, or 3
	lastClaimTimestamp?: number; // Unix timestamp (ms)
	firstRewardClaimTimestamp?: number; // Unix timestamp (ms) for the 4-hour window start
	canClaimAnyRewardToday: boolean; // Whether the overall system allows claiming (resets daily/4hr)
	notificationsEnabled: boolean;
}

export const DEFAULT_DAILY_REWARDS_STATE: DailyRewardsState = {
	currentRewards: [],
	rewardsCollectedToday: 0,
	lastClaimTimestamp: undefined,
	firstRewardClaimTimestamp: undefined,
	canClaimAnyRewardToday: true,
	notificationsEnabled: false // Start with notifications off by default
};
