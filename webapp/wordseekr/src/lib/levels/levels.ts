import { databaseService } from '$lib/database/database.service';
import type { Level } from '$lib/database/types';
import { levelsStorage, type LevelsStorage } from '$lib/storage/local-storage';
import { writable, type Readable, type Writable } from 'svelte/store';

export interface LevelProgress {
	currentLevel: Level;
	nextLevel: Level;
	progress: number;
}

class LevelsManager {
	private storage: LevelsStorage;
	private _currentLevelNumber: Writable<number> = writable(0);
	private __isInitialized: boolean = false;
	private _isInitialized: Writable<boolean> = writable(false);
	private _progress: Writable<number> = writable(0);
	__currentLevel: Level | undefined = undefined;
	private _currentLevel: Writable<Level | undefined> = writable(this.__currentLevel);

	currentLevelNumber: Readable<number> = this._currentLevelNumber;
	gridIdsCompleted: number[] = [];
	isInitialized: Readable<boolean> = this._isInitialized;
	progress: Readable<number> = this._progress;
	currentLevel: Readable<Level | undefined> = this._currentLevel;
	level: Level | undefined = undefined;

	constructor(storage: LevelsStorage) {
		this.storage = storage;
		this._isInitialized.subscribe((value) => {
			this.__isInitialized = value;
		});
		this._currentLevel.subscribe((level) => {
			this.__currentLevel = level;
			this.level = level;
		});
	}

	async init() {
		if (this.__isInitialized) {
			return;
		}
		try {
			let currentLevelNumber = await this.storage.getCurrentLevelNumber();
			if (currentLevelNumber === 0) {
				currentLevelNumber = 1;
			}
			this._currentLevelNumber.set(currentLevelNumber);
			await this.storage.setCurrentLevelNumber(currentLevelNumber);
			this.gridIdsCompleted = await this.storage.getGridIdsCompletedForLevel(currentLevelNumber);
			const level = await this.getLevel(currentLevelNumber);
			this._currentLevel.set(level);
			this.updateProgress();
			this._isInitialized.set(true);
		} catch (error) {
			console.error('🙏 levelsManager init error', JSON.stringify(error));
		}
	}

	private async getLevel(levelNumber: number): Promise<Level> {
		const level = await databaseService.getLevel(levelNumber);
		if (!level) {
			throw new Error(`Level not found ${levelNumber}`);
		}
		return level;
	}

	async getCurrentLevel(): Promise<Level> {
		const currentLevelNumber = await this.storage.getCurrentLevelNumber();
		const level = await this.getLevel(currentLevelNumber);
		return level;
	}

	async getNextGridId(): Promise<number> {
		const currentLevelNumber = await this.storage.getCurrentLevelNumber();
		const level = await this.getLevel(currentLevelNumber);
		const gridIds = level.gridIds;
		const nextGridId = gridIds[this.gridIdsCompleted.length];
		return nextGridId;
	}

	getCurrentProgress(): number {
		const totalGrids = this.__currentLevel?.gridIds.length ?? 0;
		const progress = totalGrids > 0 ? this.gridIdsCompleted.length / totalGrids : 0;
		return progress;
	}

	private updateProgress(): number {
		const progress = this.getCurrentProgress();
		this._progress.set(progress);
		return progress;
	}

	private async progressLevel() {
		const currentLevelNumber = await this.storage.getCurrentLevelNumber();
		const nextLevelNumber = currentLevelNumber + 1;
		const nextLevel = await databaseService.getLevel(nextLevelNumber);
		if (nextLevel) {
			await this.storage.setCurrentLevelNumber(nextLevel.orderIndex);
			this._currentLevelNumber.set(nextLevel.orderIndex);
			this.__currentLevel = nextLevel;
			this._currentLevel.set(nextLevel);
			this.gridIdsCompleted = [];
			this.updateProgress();
		}
	}

	async markGridAsCompleted(gridId: number): Promise<number> {
		this.gridIdsCompleted.push(gridId);
		const currentLevelNumber = await this.storage.getCurrentLevelNumber();
		this._currentLevel.set(await this.getLevel(currentLevelNumber));
		await this.storage.setGridIdsCompletedForLevel(currentLevelNumber, this.gridIdsCompleted);

		const currentProgress = this.updateProgress();

		if (currentProgress >= 1) {
			this.progressLevel();
		}
		return currentProgress;
	}
}

export const levelsManager = new LevelsManager(levelsStorage);
