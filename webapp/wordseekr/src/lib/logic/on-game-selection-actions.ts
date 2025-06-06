import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
import { gameCounter } from '$lib/storage/local-storage';

export enum OnAppearAction {
	DoNothing,
	ShowQuoteModal,
	ShowRewardModal
}

export async function onGameSelectionAppear(): Promise<OnAppearAction> {
	const isNewUser = (await gameCounter.getCount()) === 0;
	if (isNewUser) {
		return OnAppearAction.DoNothing;
	}
	const isQuoteChallengeAvailable = true;
	if (isQuoteChallengeAvailable) {
		return OnAppearAction.ShowQuoteModal;
	}
	const isFreeRewardAvailable = await dailyRewardsStore.isFreeRewardAvailable();
	console.log('🔍🔍🔍ℹ isFreeRewardAvailable', isFreeRewardAvailable);
	if (isFreeRewardAvailable) {
		return OnAppearAction.ShowRewardModal;
	}
	return OnAppearAction.DoNothing;
}
