<script lang="ts">
	import BigCoinPile from '$lib/components/Icons/BigCoinPile.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import Confetti from 'svelte-confetti';
	import { cubicOut, cubicIn, cubicInOut } from 'svelte/easing';
	import { fade, scale } from 'svelte/transition';

	interface Props {
		message: string;
		showDoubleButton: boolean;
		onClickContinue: () => void;
		onClickDouble: () => void;
	}
	const { onClickContinue, onClickDouble, message, showDoubleButton }: Props = $props();
	const base64 =
		'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nO3ZP0oDQRiG8UGwsFKwsLD2AF7AC5hoZesVvIIgAVtLW0tvoOCfTg9gr2BjYaNJYSH+ZEgCi42bqNmZdZ5+v92H9/t2Z3ZCKBQKU4FtXGOgeQa4QndSiUPp0pskidTp1BGJ7ZQ6l3VE+tLntY5IFoQikhihJPKPEuniXu4iYXjtAvbx9ruPPWORSo01nE1bKxmRSq3Ybo/T1kxGZFRvEUd4z1pkDNZxk71IBHPYxXPWImOwjGN8ZC0yBhu4y14kgnnsTbp9CKmJVO67ipO2iJxmK9KK1pL7sGNlNA95vn614YNouES5/alAYyJYyn7RiB08/aZAExur82lrNS7Siq0utvBgRoQ/FJkpoYgkRiiJZJhIX/q81BGJp6epc1FHJP4dTJ3Nb0VGMj3pclBLoiLTiaenicxMP7ZT7SQKhUL4yieOYHQusx8oEQAAAABJRU5ErkJggg==';

	let buttonDisabled = $state(false);
	async function onClickContinue_() {
		buttonDisabled = true;
		onClickDouble();
	}

	async function onClickDouble_() {
		buttonDisabled = true;
		onClickContinue();
	}
</script>

<div
	in:fade={{ delay: 300, duration: 300, easing: cubicOut }}
	out:fade={{ delay: 500, duration: 300, easing: cubicIn }}
	class="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
>
	<div
		in:scale={{ delay: 600, duration: 300, easing: cubicInOut }}
		out:scale={{ duration: 300, easing: cubicInOut }}
		class="flex flex-col items-center gap-4 rounded-xl bg-white px-8 py-8 text-center shadow-xl"
	>
		<h2 class="text-3xl font-bold text-gray-900">🎉 Well done! 🎉</h2>
		<p class="text-lg text-gray-700" style="white-space: pre-line;">{message}</p>

		<div class="w-24">
			<BigCoinPile id="coin-pile-icon" />
		</div>

		<div class="mt-2 flex gap-4">
			<button
				class="rounded bg-blue-500 px-4 py-2 text-white transition hover:bg-blue-600"
				onclick={onClickDouble_}
			>
				New Game
			</button>
			{#if showDoubleButton}
				<button
					class="flex items-center gap-1 rounded bg-emerald-500 px-4 py-2 text-white transition hover:bg-emerald-600"
					onclick={onClickContinue_}
				>
					<img class="h-5 w-5" src={base64} alt="" />
					Double Reward
				</button>
			{/if}
		</div>
	</div>
</div>
