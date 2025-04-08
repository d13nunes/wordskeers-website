import { writable } from 'svelte/store';
import type { Component } from 'svelte';
interface ModalProps {
	close: () => void;
}

interface ModalState {
	component: Component | null;
	props: ModalProps;
	isOpen: boolean;
}

const initialState: ModalState = {
	component: null,
	props: {
		close: () => {}
	},
	isOpen: false
};

export const modal = writable<ModalState>(initialState);

export function openModal(component: Component, props: ModalProps) {
	modal.set({ component, props, isOpen: true });
}

export function closeModal() {
	modal.set(initialState);
}
