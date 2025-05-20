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
async function scheduleNextRewardNotification(date: Date): Promise<void> {
	await cancelScheduledNotifications(); // Cancel previous notifications
	const options: ScheduleOptions = {
		notifications: [
			{
				id: NEXT_REWARD_NOTIFICATION_ID,
				title: 'Free Coins!',
				body: 'Your reward is available!\nCome back and claim your free coins.',
				schedule: { at: date, allowWhileIdle: true },
				channelId: Capacitor.getPlatform() === 'android' ? NOTIFICATION_CHANNEL_ID : undefined
			}
		]
	};

	try {
		const result = await LocalNotifications.schedule(options);
		console.debug('📨 Scheduled reward notification result:', JSON.stringify(result, null, 2));

		// Verify the notification was scheduled
		const pending = await LocalNotifications.getPending();
		console.debug('📨 Pending notifications after scheduling:', JSON.stringify(pending, null, 2));
	} catch (error) {
		console.error('Error scheduling notification:', error);
		throw error; // Re-throw to handle in the calling code
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
