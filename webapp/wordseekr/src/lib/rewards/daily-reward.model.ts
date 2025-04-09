export interface DailyReward {
	id: string; // Unique identifier for the reward in the current set
	status: DailyRewardStatus;
	coins: number;
	requiresAd: boolean;
}

export enum DailyRewardStatus {
	Locked = 'locked',
	Claimable = 'claimable',
	Claimed = 'claimed'
}
