<script lang="ts">
	import type { Snippet } from 'svelte';
	import GameModeIconTitle from '../GameModeIconTitle.svelte';
	import LevelsGiftIcon from '../Levels/LevelsGiftIcon.svelte';
	import Modal from '../Modal.svelte';

	interface Props {
		icon?: string;
		title: string;
		subtitle: string;
		continueButtonText: string;
		doubleButtonText: string;
		showDoubleButton: boolean;
		onRewardAnimationCompleted: () => void;
		onRewardGiven: () => void;
		onClickContinue: () => Promise<void>;
		onClickDouble: () => Promise<void>;
		children: Snippet;
	}
	const {
		showDoubleButton,
		title,
		icon,
		subtitle,
		continueButtonText,
		doubleButtonText,
		onClickContinue,
		onClickDouble,
		onRewardAnimationCompleted,
		onRewardGiven,
		children
	}: Props = $props();

	const base64 =
		'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nO3ZP0oDQRiG8UGwsFKwsLD2AF7AC5hoZesVvIIgAVtLW0tvoOCfTg9gr2BjYaNJYSH+ZEgCi42bqNmZdZ5+v92H9/t2Z3ZCKBQKU4FtXGOgeQa4QndSiUPp0pskidTp1BGJ7ZQ6l3VE+tLntY5IFoQikhihJPKPEuniXu4iYXjtAvbx9ruPPWORSo01nE1bKxmRSq3Ybo/T1kxGZFRvEUd4z1pkDNZxk71IBHPYxXPWImOwjGN8ZC0yBhu4y14kgnnsTbp9CKmJVO67ipO2iJxmK9KK1pL7sGNlNA95vn614YNouES5/alAYyJYyn7RiB08/aZAExur82lrNS7Siq0utvBgRoQ/FJkpoYgkRiiJZJhIX/q81BGJp6epc1FHJP4dTJ3Nb0VGMj3pclBLoiLTiaenicxMP7ZT7SQKhUL4yieOYHQusx8oEQAAAABJRU5ErkJggg==';
	let canAnimateReward = $state(false);
	let buttonDisabled = $state(false);

	async function onClickContinue_() {
		buttonDisabled = true;
		await onClickDouble();
		canAnimateReward = true;
	}

	async function onClickDouble_() {
		buttonDisabled = true;
		await onClickContinue();
		canAnimateReward = true;
	}

	async function onGiftClick() {
		buttonDisabled = true;
		if (showDoubleButton) {
			await onClickDouble();
		} else {
			await onClickContinue();
		}
		canAnimateReward = true;
	}
</script>

<Modal backgroundOpacity={50}>
	<div class="mt-4 flex max-w-sm min-w-2xs flex-col items-center gap-4">
		<GameModeIconTitle {icon} {title} {subtitle} />
		<button class="mt-2" onclick={onGiftClick}>
			<LevelsGiftIcon
				animateCoin={canAnimateReward}
				onGiveReward={onRewardGiven}
				onCoinAnimationCompleted={onRewardAnimationCompleted}
			/>
		</button>

		{@render children()}

		<div class="mt-2 flex w-full gap-4">
			<button
				class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-blue-800 px-4 py-2 text-xl font-bold text-white"
				onclick={onClickDouble_}
			>
				{continueButtonText}
			</button>
			{#if showDoubleButton}
				<button
					class="button-active mt-0 flex w-full flex-row items-center justify-center gap-1 rounded-md bg-green-800 px-4 py-2 text-xl font-bold text-white"
					onclick={onClickContinue_}
				>
					<img class="h-5 w-5" src={base64} alt="" />
					{doubleButtonText}
				</button>
			{/if}
		</div>
	</div>
</Modal>
