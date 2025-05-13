import { Capacitor } from '@capacitor/core';
import {
	LocalNotifications,
	type ScheduleOptions,
	type PermissionStatus,
	type PendingLocalNotificationSchema
} from '@capacitor/local-notifications';
import {
	NOTIFICATION_CHANNEL_ID,
	NOTIFICATION_CHANNEL_NAME,
	NOTIFICATION_CHANNEL_DESCRIPTION,
	NEXT_REWARD_NOTIFICATION_ID
} from './daily-rewards.config';
import { addHours, startOfTomorrow, addDays } from 'date-fns';

/**
 * Checks notification permissions.
 * @returns true if permissions are granted, false otherwise.
 */
async function checkPermissions(): Promise<boolean> {
	if (!Capacitor.isPluginAvailable('LocalNotifications')) {
		console.warn('📨LocalNotifications plugin not available');
		return false;
	}
	const result = await LocalNotifications.checkPermissions();
	return result.display === 'granted';
}

/**
 * Requests notification permissions.
 * @returns true if permissions are granted, false otherwise.
 */
async function requestPermissions(): Promise<boolean> {
	if (!Capacitor.isPluginAvailable('LocalNotifications')) {
		console.warn('📨LocalNotifications plugin not available');
		return false;
	}
	const result = await LocalNotifications.requestPermissions();
	return result.display === 'granted';
}

/**
 * Creates the notification channel if it doesn't exist (Android).
 */
async function createNotificationChannel(): Promise<void> {
	if (Capacitor.getPlatform() !== 'android' || !Capacitor.isPluginAvailable('LocalNotifications')) {
		console.log('📨Notification channel not available on this platform.');
		return;
	}
	try {
		await LocalNotifications.createChannel({
			id: NOTIFICATION_CHANNEL_ID,
			name: NOTIFICATION_CHANNEL_NAME,
			description: NOTIFICATION_CHANNEL_DESCRIPTION,
			importance: 4, // High importance
			visibility: 1 // Public visibility
		});
		console.log(`📨Notification channel '${NOTIFICATION_CHANNEL_ID}' created or already exists.`);
	} catch (error) {
		console.error('Error creating notification channel:', error);
	}
}

/**
 * Schedules a notification for when the next reward cycle begins.
 * @param firstRewardClaimTimestamp Timestamp (ms) when the first reward was claimed, if any.
 * @param lastClaimTimestamp Timestamp (ms) of the very last claim.
 */
async function scheduleNextRewardNotification(firstRewardClaimTimestamp: number): Promise<void> {
	if (!Capacitor.isPluginAvailable('LocalNotifications')) {
		console.warn('📨LocalNotifications plugin not available');
		return;
	}

	await cancelScheduledNotifications(); // Cancel previous notifications

	const now = Date.now();
	let scheduleTime: Date | undefined;

	// 4-hour window active or just ended
	const fourHoursLater = addHours(new Date(firstRewardClaimTimestamp), 4);
	if (fourHoursLater.getTime() > now) {
		scheduleTime = fourHoursLater; // Schedule for the end of the 4-hour window
	}
	// const nextMorning = addHours(startOfTomorrow(), 8);
	// if (nextMorning.getTime() > now) {
	// 	scheduleTime = nextMorning; // Schedule for the start of the next day
	// }

	// const nextMorningTwoDaysLater = addHours(addDays(startOfTomorrow(), 2), 8);
	// if (nextMorningTwoDaysLater.getTime() > now) {
	// 	scheduleTime = nextMorningTwoDaysLater; // Schedule for the start of the next day
	// }
	// const nextMorningOneWeekLater = addHours(addDays(startOfTomorrow(), 7), 8);
	// if (nextMorningOneWeekLater.getTime() > now) {
	// 	scheduleTime = nextMorningOneWeekLater; // Schedule for the start of the next week
	// }

	// If we still don't have a schedule time, it means rewards are likely available now
	// or it's the very first time, so we don't schedule a notification yet.
	if (!scheduleTime) {
		console.log('📨No future reward notification needed at this time.');
		return;
	}

	// Ensure the schedule time is in the future
	if (scheduleTime.getTime() <= now) {
		console.log('📨Calculated schedule time is in the past, skipping notification.');
		return;
	}

	const options: ScheduleOptions = {
		notifications: [
			{
				id: NEXT_REWARD_NOTIFICATION_ID,
				title: 'WordSeekr Daily Reward',
				body: 'Your next daily reward is available! Come back and claim it.',
				schedule: { at: scheduleTime },
				channelId: Capacitor.getPlatform() === 'android' ? NOTIFICATION_CHANNEL_ID : undefined,
				smallIcon: 'res://ic_stat_notify', // Example: ensure you have this resource
				largeIcon: 'res://ic_launcher' // Example: ensure you have this resource
			}
		]
	};

	try {
		const result = await LocalNotifications.schedule(options);
		console.log('📨Scheduled reward notification:', result, 'at:', scheduleTime);
	} catch (error) {
		console.error('Error scheduling notification:', error);
	}
}

/**
 * Cancels the scheduled "next reward" notification.
 */
async function cancelScheduledNotifications(): Promise<void> {
	if (!Capacitor.isPluginAvailable('LocalNotifications')) {
		return;
	}
	try {
		const pending = await LocalNotifications.getPending();
		const notificationIdsToCancel = pending.notifications
			.filter((notif: PendingLocalNotificationSchema) => notif.id === NEXT_REWARD_NOTIFICATION_ID)
			.map((notif: PendingLocalNotificationSchema) => ({ id: notif.id }));

		if (notificationIdsToCancel.length > 0) {
			await LocalNotifications.cancel({ notifications: notificationIdsToCancel });
			console.log('📨Cancelled pending reward notification(s).');
		}
	} catch (error) {
		console.error('Error cancelling notifications:', error);
	}
}

/**
 * Initializes the notification system (permissions, channel).
 * @returns The current permission status.
 */
async function initializeNotifications(): Promise<PermissionStatus | null> {
	if (!Capacitor.isPluginAvailable('LocalNotifications')) {
		console.warn('LocalNotifications plugin not available');
		return null;
	}
	await createNotificationChannel(); // Ensure channel exists on Android
	return LocalNotifications.checkPermissions();
}

export const DailyRewardsNotifications = {
	checkPermissions,
	requestPermissions,
	scheduleNextRewardNotification,
	cancelScheduledNotifications,
	initializeNotifications
};
