// Configuration for the daily rewards system

export const REWARD_COUNT = 3;
export const RESET_WINDOW_HOURS = 4;
export const RESET_WINDOW_MS = RESET_WINDOW_HOURS * 60 * 60 * 1000;

// Coin ranges for rewards
export const COIN_RANGES: { min: number; max: number }[] = [
	{ min: 10, max: 50 }, // Reward 1 (Free)
	{ min: 50, max: 100 }, // Reward 2 (Ad)
	{ min: 100, max: 200 } // Reward 3 (Ad)
];

// Local storage key
export const DAILY_REWARDS_STORAGE_KEY = 'dailyRewardsState';

// Notification details
export const NOTIFICATION_CHANNEL_ID = 'daily_rewards_channel';
export const NOTIFICATION_CHANNEL_NAME = 'Daily Rewards';
export const NOTIFICATION_CHANNEL_DESCRIPTION = 'Notifications for daily reward availability';
export const NEXT_REWARD_NOTIFICATION_ID = 1001; // Unique ID for the "next reward" notification
