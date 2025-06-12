import type { Difficulty } from '$lib/game/difficulty';
import { FirebaseAnalytics } from '@capacitor-firebase/analytics';
import { Capacitor } from '@capacitor/core';

export enum AnalyticsEvent {
	StartGame = 'start_game',
	CompleteGame = 'complete_game',
	QuitGame = 'quit_game',
	UsePowerUp = 'use_power_up',
	TryUsePowerUp = 'try_use_power_up',
	FailedToUsePowerUp = 'failed_to_use_power_up',
	StoredOpen = 'stored_open',
	StoredClosed = 'stored_closed',
	RewardsOpen = 'rewards_open',
	RewardsCollected = 'rewards_collected',
	RewardsCollectedAd = 'rewards_collected_ad',
	RewardsClosed = 'rewards_closed',
	MarkQuoteAsPlayed = 'mark_quote_as_played',
	StartedPlayingQuote = 'started_playing_quote'
}

class Analytics {
	isDev = import.meta.env.DEV;
	constructor() {}

	init() {
		console.log('init');
	}

	startGame(difficulty: Difficulty, grid_id: string) {
		const eventName = AnalyticsEvent.StartGame + '_' + difficulty.toLowerCase();
		this.track(eventName, { difficulty, grid_id });
	}

	startedPlayingQuote(id: number) {
		this.track(AnalyticsEvent.StartedPlayingQuote, { id });
	}

	markQuoteAsPlayed(id: number) {
		this.track(AnalyticsEvent.MarkQuoteAsPlayed, { id });
	}

	completeGame(difficulty: string, grid_id: string) {
		const eventName = AnalyticsEvent.CompleteGame + '_' + difficulty.toLowerCase();
		this.track(eventName, { difficulty, grid_id });
	}

	quitGame(difficulty: string, grid_id: string) {
		const eventName = AnalyticsEvent.QuitGame + '_' + difficulty.toLowerCase();
		this.track(eventName, { difficulty, grid_id });
	}

	tryUsePowerUp(powerUp: string) {
		const eventName = AnalyticsEvent.TryUsePowerUp + '_' + powerUp.toLowerCase();
		this.track(eventName, { powerUp });
	}

	usePowerUp(powerUp: string) {
		const eventName = AnalyticsEvent.UsePowerUp + '_' + powerUp.toLowerCase();
		this.track(eventName, { powerUp });
	}
	failedToUsePowerUp(powerUp: string) {
		const eventName = AnalyticsEvent.FailedToUsePowerUp + '_' + powerUp.toLowerCase();
		this.track(eventName, { powerUp });
	}

	storedOpen() {
		this.track(AnalyticsEvent.StoredOpen, {});
	}

	storedClosed() {
		this.track(AnalyticsEvent.StoredClosed, {});
	}

	rewardsOpen() {
		this.track(AnalyticsEvent.RewardsOpen, {});
	}

	rewardsClosed() {
		this.track(AnalyticsEvent.RewardsClosed, {});
	}

	rewardCollected() {
		this.track(AnalyticsEvent.RewardsCollected, {});
	}

	rewardCollectedAd() {
		this.track(AnalyticsEvent.RewardsCollectedAd, {});
	}

	track(event: string, properties: Record<string, unknown>) {
		console.log('🔍 track', event, properties);
		if (this.isDev) {
			return;
		}
		console.log('🔍 Capacitor.getPlatform()', import.meta.env, Capacitor.getPlatform());
		if (Capacitor.getPlatform() !== 'web') {
			FirebaseAnalytics.logEvent({
				name: event,
				params: {
					...properties
				}
			});
		}
		// FirebaseAnalytics.logEvent({
		// 	name: event,
		// 	params: {
		// 		...properties
		// 	}
		// });
	}
}

export const analytics = new Analytics();
