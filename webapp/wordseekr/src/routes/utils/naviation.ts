import { goto } from '$app/navigation';
import type { Difficulty } from '$lib/game/difficulty';
import { levelsManager } from '$lib/levels/levels';

export function gotoMainMenu() {
	goto('/main-menu', {
		replaceState: true
	});
}

export async function gotoNextLevel(delay: number): Promise<void> {
	console.log('gotoNextLevel', delay);
	const currentLevelNumber = (await levelsManager.getCurrentLevel()).orderIndex;
	const id = await levelsManager.getNextGridId();
	console.log('gotoNextLevel', id, currentLevelNumber);
	return new Promise((resolve) => {
		setTimeout(() => {
			console.log('gotoNextLevel', id, currentLevelNumber);
			gotoLevel(id, currentLevelNumber, true);
			resolve();
		}, delay);
	});
}

export async function gotoLevel(
	gridId: number,
	levelNumber: number,
	replaceState: boolean = false
) {
	console.log('gotoLevel', gridId, levelNumber, replaceState);
	await goto(`/game/${gridId}?difficulty=levels&level=${levelNumber}`, {
		replaceState: replaceState
	});
}

export function gotoClassicGame(id: number, difficulty: Difficulty) {
	goto(`/game/${id}?difficulty=${difficulty}`);
}

export function gotoDailyChallenge(gridId: number, id: number) {
	goto(`/game/${gridId}?dailyChallengeId=${id}&difficulty=challenge`);
}
