<script lang="ts">
	import { type Position } from './Position';
	import { PathValidator } from './PathValidator';
	import type { ColorTheme } from './color-generator';
	import { animate, createTimeline, Timeline, utils } from 'animejs';
	import { getPositionId } from '$lib/utils/string-utils';
	import { onDestroy, onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import OnboardingHand from '../Onboarding/OnboardingHand.svelte';
	import { number } from '$lib/paraglide/registry';
	interface Cell {
		letter: string;
		row: number;
		col: number;
		isDiscovered: boolean;
		isDiscoveredColor: string | null;
	}
	interface Props {
		grid: string[][];
		isRotated: boolean;
		hintPositions: Position[];
		onWordSelect: (word: string, path: Position[], letterSize: number) => Position[];
		currentColor: ColorTheme;
		class?: string;
		onboardingPositions?: Position[];
	}

	// Add some constraints to prevent cells from getting too small or too large
	const minFactor = 0.6;
	const maxFactor = getIsSmallScreen() ? 2.5 : 1.8;

	let discoveredColorMapping: Record<string, string> = $state({});
	let selectedCells: Position[] = $state([]);
	let firstSelectedCell: Position | null = null;
	let isAnimatingIsDiscovered = false;
	let pathValidator = new PathValidator();
	let {
		grid,
		onWordSelect,
		currentColor,
		isRotated = false,
		hintPositions = [],
		class: classProp = '',
		onboardingPositions = []
	}: Props = $props();

	// Calculate number of columns dynamically
	let numColumns = grid[0]?.length || 3; // Default to 3 if grid is empty

	let isInteracting = false;

	let cells: Cell[][] = $state(
		grid.map((row, rowIndex) => {
			return row.map((letter, colIndex) => {
				return {
					letter: letter,
					row: rowIndex,
					col: colIndex,
					isSelected: false,
					isDiscovered: false,
					isHint: false,
					isDiscoveredColor: null
				};
			});
		})
	);

	let previousHints: Position[] = [];
	const defaultColor = '#FE0000';

	function handleInteractionStart(rowIndex: number, colIndex: number) {
		isInteracting = true;
		const position = { row: rowIndex, col: colIndex };
		updateSelectedCells([position]);
		firstSelectedCell = position;
	}

	function setDiscovered(position: Position[]) {
		position.forEach((pos) => {
			discoveredColorMapping[getPositionId(pos.row, pos.col)] = currentColor?.bgHex ?? defaultColor;
		});
	}

	function handleInteractionEnd() {
		if (isInteracting) {
			isInteracting = false;
			const cells = Array.from(selectedCells);
			try {
				// Get the selected word by combining the letters from the selected cells
				const selectedWord = cells
					.map((cell) => {
						return grid[cell.row][cell.col];
					})
					.join('');

				// Call the callback with the selected word and path

				const discoveredPositions = onWordSelect(selectedWord, cells, fontSize);
				if (discoveredPositions.length > 0) {
					clearIdleAnimationTimer();
					setDiscovered(discoveredPositions);
					animateDiscovered(discoveredPositions);
					resetSelectedCells();
				} else {
					animateWrongWord(cells);
				}
			} catch (error) {
				console.error('🔍🔍🔍ℹ handleInteractionEnd', error);
				resetSelectedCells();
			}
		}
	}

	function handleInteractionMove(rowIndex: number, colIndex: number) {
		if (isInteracting) {
			const newCell = { row: rowIndex, col: colIndex };
			if (firstSelectedCell) {
				// Use pathValidator to check if the new cell forms a valid path with the last selected cell
				const isValid = pathValidator.isValidPath(firstSelectedCell, newCell);
				if (isValid) {
					const positions = pathValidator.getPositionsInPath(firstSelectedCell, newCell);
					updateSelectedCells(positions);
				}
			} else {
				updateSelectedCells([newCell]);
			}
		}
	}

	function handleInteractionCancel() {
		handleInteractionEnd();
	}

	// Touch event handlers
	function handleTouchStart(event: TouchEvent, rowIndex: number, colIndex: number) {
		event.preventDefault();
		cancelOnBoardingAnimation();
		handleInteractionStart(rowIndex, colIndex);
	}

	function handleTouchMove(event: TouchEvent) {
		if (!isInteracting) {
			return;
		}
		const touch = event.touches[0];
		const element = document.elementFromPoint(touch.clientX, touch.clientY);
		if (!element) return;

		// Find the cell div that was touched
		const cellDiv = element.closest('[data-row][data-col]');
		if (cellDiv) {
			const rowIndex = parseInt(cellDiv.getAttribute('data-row') || '0');
			const colIndex = parseInt(cellDiv.getAttribute('data-col') || '0');
			handleInteractionMove(rowIndex, colIndex);
		}
	}

	function handleTouchEnd(event: TouchEvent) {
		event.preventDefault();
		cancelOnBoardingAnimation();
		handleInteractionEnd();
	}

	function handleTouchCancel(event: TouchEvent) {
		event.preventDefault();
		cancelOnBoardingAnimation();
		handleInteractionCancel();
	}

	// Mouse event handlers (renamed from the originals)
	function handleMouseDown(rowIndex: number, colIndex: number) {
		cancelOnBoardingAnimation();
		handleInteractionStart(rowIndex, colIndex);
	}

	function handleMouseUp() {
		cancelOnBoardingAnimation();
		handleInteractionEnd();
	}

	function handleMouseLeave() {
		handleInteractionCancel();
	}

	function updateSelectedCells(newCells: Position[]) {
		selectedCells.forEach((position) => {
			animatedDeselect(position);
		});
		newCells.forEach((position) => {
			animatedSelect(position);
		});
		selectedCells.length = 0;
		selectedCells.push(...newCells);
	}

	function resetSelectedCells() {
		updateSelectedCells([]);
	}

	function animatedSelect(position: Position) {
		const cell = document.getElementById(getPositionId(position.row, position.col));
		if (cell) {
			animate(cell, {
				backgroundColor: [currentColor.isSelectedColorHex],
				duration: 1,
				ease: 'inOutQuad'
			});
		}
	}

	function animatedDeselect(position: Position) {
		if (isAnimatingIsDiscovered) return;
		const id = getPositionId(position.row, position.col);
		const cell = document.getElementById(id);
		if (cell) {
			animate(cell, {
				scale: [1, 1.1, 1],
				opacity: [1, 0.8, 1],
				backgroundColor: discoveredColorMapping[id] ?? '#ffffff',
				duration: 1,
				ease: 'inOutQuad'
			});
		}
	}

	function animatedHint(position: Position) {
		const cell = document.getElementById(getPositionId(position.row, position.col));
		if (cell) {
			const colorTheme = currentColor;
			const backgroundColor =
				discoveredColorMapping[getPositionId(position.row, position.col)] ?? '#ffffff';
			animate(cell, {
				rotate: [0, -5, +5, -5, +5, -5, +5, 0],
				duration: 1000,
				backgroundColor: [backgroundColor, colorTheme.hintHex, colorTheme.hintHex],
				ease: 'inOutQuad',
				delay: 900
			});
		}
	}

	function animateWrongWord(positions: Position[]) {
		positions.forEach((position) => {
			const cell = document.getElementById(getPositionId(position.row, position.col));
			if (cell) {
				const backgroundColor =
					discoveredColorMapping[getPositionId(position.row, position.col)] ?? '#ffffff';
				animate(cell, {
					rotate: [-5, +5, -5, +5, -5, 0],
					duration: 300,
					ease: 'inOutQuad',
					backgroundColor: backgroundColor
				});
			}
		});
	}

	function animateDiscovered(positions: Position[]) {
		const colorTheme = currentColor;
		isAnimatingIsDiscovered = true;

		positions.forEach((position, index) => {
			const cell = document.getElementById(getPositionId(position.row, position.col));
			const delay = index * 50;
			const isLast = index === positions.length - 1;
			if (cell) {
				animate(cell, {
					delay: delay,
					scale: [1, 0.9, 1.1, 1],
					duration: 300,
					backgroundColor: [
						colorTheme.isSelectedColorHex,
						colorTheme.isSelectedColorHex,
						colorTheme.bgHex
					],
					ease: 'linear',
					onComplete: () => {
						if (isLast) {
							isAnimatingIsDiscovered = false;
						}
					}
				});
			}
		});
	}

	interface CellBaseValues {
		squareSize: number;
		letterSize: number;
		fontSize: number;
	}

	const cellBaseValues: CellBaseValues = {
		squareSize: 34,
		letterSize: 32,
		fontSize: 22
	};

	let factor = $state(0.5);
	let boardElement: HTMLElement | null = null;
	let boardWidth: number = $state(0);
	let isInitialized = $state(false);
	let resizeTimeout: number | null = null;

	const squareSize = $derived(cellBaseValues.squareSize * factor);
	const letterSize = $derived(cellBaseValues.letterSize * factor);
	const fontSize = $derived(cellBaseValues.fontSize * factor);

	function updateFactor(width: number) {
		// Calculate the total width needed for the grid without padding
		const totalGridWidth = numColumns * cellBaseValues.squareSize;
		// Calculate the available width (subtract padding)
		const availableWidth = width - 16; // 16px for padding
		// Calculate the factor needed to fit the grid in the available width
		let newFactor = availableWidth / totalGridWidth;

		if (newFactor > maxFactor) newFactor = maxFactor;
		if (newFactor < minFactor) newFactor = minFactor;

		// Only update if the factor has changed significantly
		if (Math.abs(newFactor - factor) > 0.01) {
			factor = newFactor;
		}
	}

	function debouncedUpdate(newWidth: number) {
		if (resizeTimeout) {
			window.cancelAnimationFrame(resizeTimeout);
		}
		resizeTimeout = window.requestAnimationFrame(() => {
			if (Math.abs(newWidth - boardWidth) > 1) {
				boardWidth = newWidth;
				updateFactor(newWidth);
			}
			resizeTimeout = null;
		});
	}

	let ignoredFirstRotationUpdate = false;
	function fixBoardRotation(newRotation: boolean) {
		if (!ignoredFirstRotationUpdate) {
			ignoredFirstRotationUpdate = true;
			return;
		}
		let previousAngle = !newRotation ? 180 : 0;
		let angle = newRotation ? 180 : 0;

		let elements = [];
		const board = document.getElementById('board');
		if (!board) {
			return;
		}
		elements.push(board);
		const cells = Array.from(board.children);
		elements.push(...cells);
		const duration = 300;
		animate(elements, {
			rotate: [previousAngle, angle],
			scale: [1, 0.8, 1],
			duration: duration
		});
	}

	onMount(() => {
		if (!boardElement) return;
		const resizeObserver = new ResizeObserver((entries) => {
			if (!isInitialized) return;
			const entry = entries[0];
			if (entry && entry.target === boardElement) {
				debouncedUpdate(entry.contentRect.width);
			}
		});
		// Initial setup
		boardWidth = boardElement.getBoundingClientRect().width;
		updateFactor(boardWidth);
		resizeObserver.observe(boardElement);
		isInitialized = true;
		return () => {
			if (resizeTimeout) {
				window.cancelAnimationFrame(resizeTimeout);
			}
			resizeObserver.disconnect();
		};
	});

	let onBoardingAnimation: Timeline | null = null;
	let idleAnimationTimer: NodeJS.Timeout | null = null;

	function clearIdleAnimationTimer() {
		if (idleAnimationTimer) {
			clearTimeout(idleAnimationTimer);
			idleAnimationTimer = null;
		}
		if (onBoardingAnimation) {
			onBoardingAnimation.cancel();
			onBoardingAnimation = null;
		}
	}

	async function cancelOnBoardingAnimation(reset: boolean = true) {
		if (idleAnimationTimer) {
			clearTimeout(idleAnimationTimer);
		}
		idleAnimationTimer = setTimeout(() => {
			animateOnBoarding(onboardingPositions);
			idleAnimationTimer = null;
		}, 7000);
		if (!onBoardingAnimation) {
			return;
		}
		if (reset) {
			console.log('👇👇👇👇 reset');
			onBoardingAnimation.reset();
		}
	}

	function animateOnBoarding(positions: Position[]) {
		if (positions.length === 0) {
			return;
		}
		if (idleAnimationTimer) {
			clearTimeout(idleAnimationTimer);
			idleAnimationTimer = null;
		}
		if (onBoardingAnimation) {
			onBoardingAnimation.play();
			return;
		}
		const partialDuration = 300;
		const totalDuration = positions.length * partialDuration + partialDuration;
		// position hand on first position
		const hand = document.getElementById('onboarding-hand');
		const firstPosition = positions[0];
		const firstPositionElement = document.getElementById(
			getPositionId(firstPosition.row, firstPosition.col)
		);
		const lastPosition = positions[positions.length - 1];
		const lastPositionElement = document.getElementById(
			getPositionId(lastPosition.row, lastPosition.col)
		);
		if (hand && firstPositionElement && lastPositionElement) {
			const firstPositionRect = firstPositionElement.getBoundingClientRect();
			const lastPositionRect = lastPositionElement.getBoundingClientRect();
			if (!handRectLeft) {
				handRectLeft = hand.getBoundingClientRect().left;
			}
			if (!handRectTop) {
				handRectTop = hand.getBoundingClientRect().top;
			}
			const handInitialPositionX =
				firstPositionRect.left - handRectLeft + firstPositionRect.width / 4;
			const handInitialPositionY =
				firstPositionRect.top - handRectTop + firstPositionRect.height * 0.75;

			const translateFinalPositionX =
				handInitialPositionX +
				lastPositionRect.left -
				firstPositionRect.left +
				lastPositionRect.width / 4;
			const translateFinalPositionY =
				handInitialPositionY + lastPositionRect.top - firstPositionRect.top;

			// move hand to initial position
			onBoardingAnimation = createTimeline({
				duration: totalDuration,
				loop: true,
				loopDelay: 1000,
				autoplay: false
			});

			onBoardingAnimation.sync(
				animate(hand, {
					opacity: [0, 1],
					duration: 1
				})
			);
			onBoardingAnimation.add(
				hand,
				{
					translateX: [handInitialPositionX, translateFinalPositionX],
					translateY: [handInitialPositionY, translateFinalPositionY],
					// rotate: [-20, 20],
					ease: 'linear',
					duration: totalDuration - partialDuration
				},
				1
			);
			onBoardingAnimation.add(
				hand,
				{
					opacity: [1, 0],
					duration: 2 * partialDuration,
					ease: 'outQuad'
				},
				totalDuration - partialDuration
			);
			const cells = positions.map((position) => {
				return document.getElementById(getPositionId(position.row, position.col)) as HTMLElement;
			});

			cells.forEach((cell, index) => {
				if (cell) {
					const position = positions[index];
					const id = getPositionId(position.row, position.col);
					onBoardingAnimation?.add(
						cell,
						{
							backgroundColor: [
								discoveredColorMapping[id] ?? '#ffffff',
								currentColor.isSelectedColorHex
							],
							duration: partialDuration,
							ease: 'linear'
						},
						index * partialDuration
					);
					onBoardingAnimation?.add(
						cell,
						{
							backgroundColor: [
								currentColor.isSelectedColorHex,
								discoveredColorMapping[id] ?? '#ffffff'
							],
							duration: partialDuration,
							ease: 'linear'
						},
						totalDuration
					);
				}
			});
		}
		onBoardingAnimation?.play();
	}

	$effect(() => {
		console.log('👇👇👇👇 onboardingPositions', onboardingPositions);
		if (onboardingPositions.length > 0) {
			if (onBoardingAnimation) {
				onBoardingAnimation.cancel();
				onBoardingAnimation = null;
			}
			idleAnimationTimer = setTimeout(() => {
				animateOnBoarding(onboardingPositions);
			}, 1);
		}
	});

	$effect(() => {
		previousHints
			.filter((position) => {
				const shouldAnimate =
					!isAnimatingIsDiscovered &&
					!discoveredColorMapping[getPositionId(position.row, position.col)];
				if (!isAnimatingIsDiscovered) {
					return true;
				}
				return shouldAnimate;
			})
			.forEach(animatedDeselect);
		hintPositions.forEach(animatedHint);
		previousHints = [...hintPositions];
	});

	// Add CSS variables for dynamic sizing
	$effect(() => {
		if (boardElement) {
			boardElement.style.setProperty('--square-size', `${squareSize}px`);
			boardElement.style.setProperty('--letter-size', `${letterSize}px`);
			boardElement.style.setProperty('--font-size', `${fontSize}px`);
		}
	});
	$effect(() => {
		fixBoardRotation(isRotated);
	});
	let handRectLeft: number | undefined = undefined;
	let handRectTop: number | undefined = undefined;

	onDestroy(() => {
		if (idleAnimationTimer) {
			clearTimeout(idleAnimationTimer);
			idleAnimationTimer = null;
		}
	});
</script>

<div bind:this={boardElement} class="flex w-full flex-col items-center justify-center {classProp}">
	{#if isInitialized}
		<div
			class="relative rounded-md bg-white p-2 shadow-md"
			onmouseleave={handleMouseLeave}
			onmouseup={handleMouseUp}
			ontouchend={handleTouchEnd}
			ontouchcancel={handleTouchCancel}
			ontouchmove={handleTouchMove}
			role="grid"
			tabindex="0"
		>
			<div id="onboarding-hand" class="pointer-events-none absolute z-100 h-10 w-10 opacity-0">
				<OnboardingHand />
			</div>
			<div
				id="board"
				class="grid"
				style="
				grid-template-columns: repeat({numColumns}, minmax(0, 1fr));
				--square-size: {squareSize}px;
				--letter-size: {letterSize}px;
				--font-size: {fontSize}px;
				transform: rotate({isRotated ? 180 : 0}deg);
			"
			>
				{#each cells as row}
					{#each row as cell}
						<div
							style="height: var(--square-size); width: var(--square-size)"
							class="flex items-center justify-center ease-in-out"
							onmousedown={() => handleMouseDown(cell.row, cell.col)}
							onmouseenter={() => handleInteractionMove(cell.row, cell.col)}
							ontouchstart={(e) => handleTouchStart(e, cell.row, cell.col)}
							ontouchend={handleTouchEnd}
							role="button"
							tabindex="0"
						>
							<div
								id={getPositionId(cell.row, cell.col)}
								style="height: var(--letter-size); width: var(--letter-size); font-size: var(--font-size) "
								class="flex items-center justify-center rounded-md text-center font-semibold text-gray-900"
								data-row={cell.row}
								data-col={cell.col}
							>
								{cell.letter}
							</div>
						</div>
					{/each}
				{/each}
			</div>
		</div>
	{/if}
</div>
