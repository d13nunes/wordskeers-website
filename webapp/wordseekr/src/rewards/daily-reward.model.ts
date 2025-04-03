export interface DailyReward {
	id: string; // Unique identifier for the reward in the current set
	coins: number;
	requiresAd: boolean;
	claimed: boolean;
	claimable: boolean; // Whether this specific reward can be claimed now
}
