import { OnAppearAction, onGameSelectionAppear } from '$lib/logic/on-game-selection-actions';
import { writable } from 'svelte/store';
import { dailyRewardsStore } from './rewards/daily-rewards.store';
import { gameCounter } from './storage/local-storage';

export const isGameModeSelectionClassic = writable(false);
export const openStoreModal = writable(false);

export function toggleGameMode() {
	isGameModeSelectionClassic.update((value) => !value);
}

export function setGameModeSelectionClassic(value: boolean) {
	isGameModeSelectionClassic.update(() => {
		return value;
	});
}

export const expandRewardsTag = writable(false);
export const animateRewardsTag = writable(false);
export const expandQuoteTag = writable(false);
export const animateQuoteTag = writable(false);
export const showQuoteModalStore = writable(false);
export const expandClassicTag = writable(false);

let hasFreeRewardToCollect = false;

dailyRewardsStore.subscribe((state) => {
	if (!state) {
		return;
	}
	hasFreeRewardToCollect = state.rewardsCollectedToday === 0;
	animateRewardsTag.set(hasFreeRewardToCollect);
});

export async function updateTagState() {
	const isNewUser = (await gameCounter.getCount()) === 0;
	const onAppearAction = await onGameSelectionAppear();

	const isRewardExpanded = !isNewUser && hasFreeRewardToCollect;
	switch (onAppearAction) {
		case OnAppearAction.DoNothing:
			expandRewardsTag.set(false);
			animateRewardsTag.set(isRewardExpanded);
			expandQuoteTag.set(false);
			animateQuoteTag.set(false);
			expandClassicTag.set(!isRewardExpanded);
			break;
		case OnAppearAction.ShowQuoteModal:
			expandQuoteTag.set(true);
			animateQuoteTag.set(!hasFreeRewardToCollect);
			expandRewardsTag.set(false);
			animateRewardsTag.set(hasFreeRewardToCollect);
			expandClassicTag.set(false);
			break;
		case OnAppearAction.ShowRewardModal:
			expandRewardsTag.set(true);
			animateRewardsTag.set(true);
			expandQuoteTag.set(false);
			animateQuoteTag.set(false);
			expandClassicTag.set(false);
			break;
	}
}
