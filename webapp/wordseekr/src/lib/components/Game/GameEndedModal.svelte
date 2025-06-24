<script lang="ts">
	import type { Snippet } from 'svelte';
	import GameModeIconTitle from '../GameModeIconTitle.svelte';
	import LevelsGiftIcon from '../Levels/LevelsGiftIcon.svelte';
	import Modal from '../Modal.svelte';
	import { adsIconBase64 } from '$lib/utils/utils';

	interface Props {
		icon?: string;
		iconId?: string;
		title: string;
		subtitle: string;
		continueButtonText: string;
		doubleButtonText: string;
		showDoubleButton: boolean;
		onClose?: () => void;
		onDismiss?: () => void;
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
		iconId,
		subtitle,
		continueButtonText,
		doubleButtonText,
		onClickContinue,
		onClickDouble,
		onRewardAnimationCompleted,
		onRewardGiven,
		onClose,
		onDismiss,
		children
	}: Props = $props();

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

<Modal backgroundOpacity={50} {onClose} {onDismiss}>
	<div class="mt-4 flex max-w-sm min-w-2xs flex-col items-center gap-4">
		<GameModeIconTitle {icon} {title} {subtitle} />
		<button class="mt-2" onclick={onGiftClick}>
			<LevelsGiftIcon
				id={iconId}
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
					<img class="h-5 w-5" src={adsIconBase64} alt="" />
					{doubleButtonText}
				</button>
			{/if}
		</div>
	</div>
</Modal>
