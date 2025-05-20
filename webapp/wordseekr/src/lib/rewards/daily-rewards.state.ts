import type { DailyReward } from './daily-reward.model';

export interface DailyRewardsState {
	currentRewards: DailyReward[];
	rewardsCollectedToday: number; // 0, 1, 2, or 3
	lastClaimDate?: Date;
	resetRewardDate?: Date;
	notificationsEnabled: boolean;
}

export const DEFAULT_DAILY_REWARDS_STATE: DailyRewardsState = {
	currentRewards: [],
	rewardsCollectedToday: 0,
	lastClaimDate: undefined,
	resetRewardDate: undefined,
	notificationsEnabled: false // Start with notifications off by default
};
