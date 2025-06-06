import { writable, type Writable } from 'svelte/store';

interface IModalPresenter {
	isQuoteModalVisible: Writable<boolean>;
	isRewardsModalVisible: Writable<boolean>;
	showQuoteModal: () => void;
	showRewardsModal: () => void;
}

class ModalPresenter implements IModalPresenter {
	isQuoteModalVisible = writable(false);
	isRewardsModalVisible = writable(false);

	showQuoteModal() {
		this.isQuoteModalVisible.set(true);
	}
	showRewardsModal() {
		this.isRewardsModalVisible.set(true);
	}
}

export const modalPresenter: IModalPresenter = new ModalPresenter();
