<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import QuoteIcon from '$lib/assets/Quote.png';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import Modal from '$lib/components/Modal.svelte';
	import { getTodaysQuote } from './quote-fetcher';
	import { databaseService } from '$lib/database/database.service';

	const quoteIconId = 'quoteIconID';

	let quote = $state('');
	let id = 0;

	interface Props {
		onClickPlay: () => void;
		onClickClose: () => void;
	}

	const { onClickPlay, onClickClose }: Props = $props();

	onMount(async () => {
		const todaysQuote = await getTodaysQuote();
		console.log('todaysQuote', todaysQuote);
		quote = todaysQuote?.author || 'Unknown';
		id = todaysQuote?.id || 0;
	});

	function onPlayClick() {
		goto(`/game?dailyChallengeId=${id}&difficulty=challenge`);
		onClickPlay();
	}
</script>

<Modal onClose={onClickClose} backgroundOpacity={50}>
	<div class="mt-2 flex flex-col items-center justify-center gap-0">
		<GameModeIconTitle
			icon={QuoteIcon}
			iconId={quoteIconId}
			title="Quotes"
			subtitle="Daily Challenge"
		/>
		<div
			class="mt-6 flex max-w-3xs flex-col items-center justify-center gap-0 text-center text-base text-gray-900"
		>
			<span class="">Search the grid to complete a famous quotation and earn your coins.</span>
		</div>
		<button
			class="button-active mt-8 w-full rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white lg:mt-8"
			onclick={onPlayClick}
		>
			Play
		</button>
	</div>
</Modal>
