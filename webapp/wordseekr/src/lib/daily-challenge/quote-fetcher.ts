import { databaseService } from '$lib/database/database.service';
import type { Quote } from '$lib/database/types';
import { syncQuotes } from '$lib/firestore/firestore';
import {
	NOTIFICATION_CHANNEL_ID,
	QUOTE_TODAY_NOTIFICATION_ID_END,
	QUOTE_TODAY_NOTIFICATION_ID_START
} from '$lib/rewards/daily-rewards.config';
import { DailyRewardsNotifications } from '$lib/rewards/daily-rewards.notifications';
import { Capacitor } from '@capacitor/core';
import {
	LocalNotifications,
	type LocalNotificationSchema,
	type PendingLocalNotificationSchema
} from '@capacitor/local-notifications';
import { addDays } from 'date-fns';

import { writable, type Readable } from 'svelte/store';

const isTodaysQuoteAvailable_ = writable(false);
let _isTodaysQuoteAvailable: boolean = false;
isTodaysQuoteAvailable_.subscribe((value) => {
	_isTodaysQuoteAvailable = value;
});

async function canScheduleNotifications(): Promise<boolean> {
	const hasPermission = await DailyRewardsNotifications.initializeNotifications();
	if (hasPermission?.display === 'granted') {
		return true;
	}
	return false;
}

async function getPendingNotifications(): Promise<PendingLocalNotificationSchema[]> {
	const pendingNotifications = await LocalNotifications.getPending();
	const filtered = pendingNotifications.notifications.filter(
		(notification) =>
			notification.id >= QUOTE_TODAY_NOTIFICATION_ID_START &&
			notification.id <= QUOTE_TODAY_NOTIFICATION_ID_END
	);
	return filtered;
}

export async function ensureScheduledNotificationForTheNNextDay(
	numberOfDays: number,
	ignoreToday: boolean = false
) {
	if (!(await canScheduleNotifications())) {
		return;
	}
	const pendingNotifications = await getPendingNotifications();
	if (pendingNotifications.length > 0) {
		await LocalNotifications.cancel({
			notifications: pendingNotifications.map((notification) => ({
				id: notification.id
			}))
		});
	}
	const playedToday = !_isTodaysQuoteAvailable;
	const today = new Date();
	today.setHours(8, 0, 0, 0);
	const startDate = playedToday || ignoreToday ? addDays(today, 1) : today;
	const notificationsToSchedule: LocalNotificationSchema[] = [];
	const channelId = Capacitor.getPlatform() === 'android' ? NOTIFICATION_CHANNEL_ID : undefined;
	for (let i = 0; i < numberOfDays; i++) {
		// increment index days from startDate
		const date = addDays(startDate, i);
		notificationsToSchedule.push({
			id: QUOTE_TODAY_NOTIFICATION_ID_START + i,
			title: 'Quote of the day is available!',
			body: "Discover today's quote and earn coins!",
			schedule: { at: date, allowWhileIdle: true },
			channelId
		});
	}

	await LocalNotifications.schedule({
		notifications: notificationsToSchedule
	});
}

export async function getAllQuotes(): Promise<Quote[]> {
	const quotes = await databaseService.getAllQuotes();
	return quotes;
}

export async function getTodaysQuote(): Promise<Quote | null> {
	try {
		syncQuotes();
	} catch (error) {
		console.error('Error trying to sync quotes:', error);
	}
	const quote = await databaseService.getQuoteForDate(new Date());
	return quote;
}

export async function isTodaysQuoteAvailable(): Promise<boolean> {
	try {
		syncQuotes();
	} catch (error) {
		console.error('Error trying to sync quotes:', error);
	}
	const quote = await getTodaysQuote();
	const isAvailable = !!(quote && quote.played_at === null);
	isTodaysQuoteAvailable_.set(isAvailable);
	return isAvailable;
}

export async function markQuoteAsPlayed(quoteId: number): Promise<void> {
	try {
		syncQuotes();
	} catch (error) {
		console.error('Error trying to sync quotes:', error);
	}
	await databaseService.markQuoteAsPlayed(quoteId, new Date());
	isTodaysQuoteAvailable_.set(false);
	await ensureScheduledNotificationForTheNNextDay(5);
}

export async function getIsTodaysQuoteAvailableStore(): Promise<Readable<boolean>> {
	const isAvailable = await isTodaysQuoteAvailable();
	isTodaysQuoteAvailable_.set(isAvailable);
	return isTodaysQuoteAvailable_;
}
