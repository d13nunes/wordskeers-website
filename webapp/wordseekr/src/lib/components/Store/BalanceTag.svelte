<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import PlusCircleIcon from '$lib/components/Icons/PlusCircleIcon.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import { isIAPAvailable } from '$lib/economy/iapStore';
	import { onMount } from 'svelte';
	import { animate, utils } from 'animejs';
	import BaseTag from '../BaseTag.svelte';
	import { formatedBalance } from '$lib/utils/string-utils';

	let balance = $state(0);
	let isActive = $state(false);
	let { onclick } = $props();
	let displayBalance = $state(0);
	let balanceTagIcon: HTMLElement | null = null;

	let isFirstUpdate = true;

	onMount(() => {
		balanceTagIcon = document.getElementById('balance-tag-icon');
	});

	walletStore.coins((newBalance) => {
		if (isFirstUpdate) {
			isFirstUpdate = false;
			balance = newBalance;
			displayBalance = balance;
			return;
		}

		if (balance !== newBalance) {
			const oldDisplayBalance = displayBalance;
			balance = newBalance;
			let counter = { value: oldDisplayBalance };
			animate(counter, {
				value: newBalance,
				duration: 1000,
				ease: 'outExpo',
				modifier: utils.round(0),
				onUpdate: function () {
					displayBalance = counter.value;
				}
			});

			if (balanceTagIcon) {
				animate(balanceTagIcon, {
					scale: [1, 1.2, 0.8, 1],
					duration: 1000,
					ease: 'inOutQuad'
				});
			}
		}
	});

	onMount(async () => {
		isActive = await isIAPAvailable();
	});
</script>

<BaseTag {onclick} disabled={!isActive} id="balance-tag">
	<div class="h-4 w-4">
		<CoinsPileIcon id="balance-tag-icon" />
	</div>
	<span class="text-black-500 min-w-8 font-mono text-sm font-medium lg:text-base"
		>{formatedBalance(displayBalance)}</span
	>

	{#if isActive}
		<div class="h-4 w-4">
			<PlusCircleIcon fillColor="#00c951" />
		</div>
	{/if}
</BaseTag>
