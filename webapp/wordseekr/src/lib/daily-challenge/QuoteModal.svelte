<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import QuoteIcon from '$lib/assets/Quote.png';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import Modal from '$lib/components/Modal.svelte';
	import { getTodaysQuote } from './quote-fetcher';
	import { gotoDailyChallenge } from '../../routes/utils/naviation';

	const quoteIconId = 'quoteIconID';

	let quote = $state('');
	let id = 0;
	let gridId = 0;

	interface Props {
		onClickPlay: () => void;
		onClickClose: () => void;
	}

	const { onClickPlay, onClickClose }: Props = $props();

	onMount(async () => {
		const todaysQuote = await getTodaysQuote();
		quote = todaysQuote?.author || 'Unknown';
		id = todaysQuote?.id || 0;
		gridId = todaysQuote?.grid_id || 0;
	});

	function onPlayClick() {
		gotoDailyChallenge(gridId, id);
		onClickPlay();
	}
</script>

<Modal onClose={onClickClose} onDismiss={onClickClose} backgroundOpacity={50}>
	<div class="mt-2 flex flex-col items-center justify-center gap-0">
		<GameModeIconTitle
			icon={QuoteIcon}
			iconId={quoteIconId}
			title="Quotes"
			subtitle="Daily Challenge"
		/>
		<div
			class="mt-6 flex max-w-3xs flex-col items-center justify-center gap-0 px-4 text-center text-base text-gray-900"
		>
			<span class=""
				>Search the grid to complete a famous quotation and <br /><b>earn 100 coins</b>.</span
			>
		</div>
		<button
			class="button-active mt-8 w-full rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white lg:mt-8"
			onclick={onPlayClick}
		>
			Play
		</button>
	</div>
</Modal>
