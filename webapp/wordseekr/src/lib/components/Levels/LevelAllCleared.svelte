<script>
	import { goto } from '$app/navigation';
	import { analytics } from '$lib/analytics/analytics';
	import { onMount } from 'svelte';
	import Confetti from 'svelte-confetti';

	function handleRateGame() {
		// Handle rating functionality
		console.log('Rate game clicked');
	}
	function handleMainMenu() {
		goto('/?classic=true');
	}

	onMount(() => {
		analytics.track('levels_allcleared', {});
	});
</script>

<div
	class=" flex min-h-screen min-w-screen flex-col items-center justify-center bg-slate-50 px-5 pt-30 pb-30"
>
	<div class="flex h-96 flex-col items-center justify-between">
		<!-- Title -->
		<h1 class=" text-center text-4xl font-bold text-gray-800 drop-shadow-md">
			MASTER<br /> WORD SEEKER
		</h1>

		<div class="flex flex-col gap-10 px-8">
			<!-- Thank you message -->
			<div class="text-center">
				<div class=" flex w-full items-center justify-center text-center">
					<Confetti
						x={[-1, 1]}
						y={[-1.5, 1.5]}
						iterationCount={1}
						duration={5000}
						amount={200}
						rounded={true}
					/>
				</div>
				<p class="mb-1 text-xl font-semibold text-gray-800">Thank you for playing through</p>
				<p class="text-xl font-semibold text-gray-800">our entire collection of puzzles!</p>
			</div>

			<!-- Rating section -->
			<!-- <div class=" flex flex-col items-center text-center">
			<p class="mb-0 text-lg font-light text-gray-700">Enjoying the game?</p>
			<p class="mb-0 text-lg font-light text-gray-700">Help us by leaving a rating.</p>

			<div class="mb-4 flex items-baseline justify-center gap-0.5">
				<span
					class="cursor-pointer text-xl text-yellow-500 transition-transform duration-200 hover:scale-110"
					>★</span
				>
				<span
					class="cursor-pointer text-xl text-yellow-500 transition-transform duration-200 hover:scale-110"
					>★</span
				>
				<span
					class="cursor-pointer text-xl text-yellow-500 transition-transform duration-200 hover:scale-110"
					>★</span
				>
				<span
					class="cursor-pointer text-xl text-yellow-500 transition-transform duration-200 hover:scale-110"
					>★</span
				>
				<span
					class="cursor-pointer text-xl text-yellow-500 transition-transform duration-200 hover:scale-110"
					>★</span
				>
			</div>
			<button
				class=" flex w-3xs flex-row items-center justify-center rounded bg-green-700 px-4 py-2 text-white hover:bg-green-800"
				onclick={handleRateGame}
			>
				RATE
			</button>
		</div> -->
		</div>
		<!-- Coming soon message -->
		<div class="flex w-2xs flex-col gap-2">
			<p class="px-2 text-base text-gray-500 italic">New puzzle packs coming soon...</p>
			<!-- Main menu button -->
			<button
				class="  rounded bg-red-800 px-4 py-2 text-white hover:bg-red-800"
				onclick={handleMainMenu}
			>
				Main Menu
			</button>
		</div>
	</div>
</div>
