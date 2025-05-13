<script lang="ts">
	import { type Position } from './Position';
	import { PathValidator } from './PathValidator';
	import type { ColorTheme } from './color-generator';
	import Confetti from 'svelte-confetti';
	import { animate } from 'animejs';
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
		isGameEnded: boolean;
		onWordSelect: (word: string, path: Position[]) => Position[];
		getColor: () => ColorTheme;
	}

	let discoveredColorMapping: Record<string, string> = $state({});
	let selectedCells: Position[] = $state([]);
	let firstSelectedCell: Position | null = null;
	let confettiConfig = $state({ amount: 500, size: 20 });
	let isAnimatingIsDiscovered = false;
	// let discoveredCells: Set<Position> = new Set();
	let pathValidator = new PathValidator();
	let {
		grid,
		onWordSelect,
		getColor,
		isRotated = false,
		hintPositions = [],
		isGameEnded = false
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
	let currentColor: ColorTheme = getColor();
	let previousHints: Position[] = [];

	function handleInteractionStart(rowIndex: number, colIndex: number) {
		isInteracting = true;
		currentColor = getColor();
		const position = { row: rowIndex, col: colIndex };
		updateSelectedCells([position]);
		firstSelectedCell = position;
	}

	const defaultColor = '#FEE2E2';

	function setDiscovered(position: Position[]) {
		position.forEach((pos) => {
			discoveredColorMapping[`${pos.row}${pos.col}`] = currentColor?.bgHex ?? defaultColor;
		});

		// Calculate confetti amount based on word length
		const wordLength = position.length;
		confettiConfig = {
			amount: Math.min(50 + wordLength * 30, 300), // More confetti for longer words, max 300
			size: Math.min(15 + wordLength * 2, 30) // Bigger confetti for longer words, max 30
		};
	}

	function handleInteractionEnd() {
		if (isInteracting) {
			isInteracting = false;
			const cells = Array.from(selectedCells);

			// Get the selected word by combining the letters from the selected cells
			const selectedWord = cells
				.map((cell) => {
					return grid[cell.row][cell.col];
				})
				.join('');

			// Call the callback with the selected word and path
			const discoveredPositions = onWordSelect(selectedWord, cells);
			if (discoveredPositions.length > 0) {
				setDiscovered(discoveredPositions);
				resetSelectedCells();
				animateDiscovered(discoveredPositions);
				currentColor = getColor();
			} else {
				animateWrongWord(cells);
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
		isInteracting = false;
		resetSelectedCells();
	}

	// Touch event handlers
	function handleTouchStart(event: TouchEvent, rowIndex: number, colIndex: number) {
		event.preventDefault();
		handleInteractionStart(rowIndex, colIndex);
	}

	function handleTouchMove(event: TouchEvent) {
		event.preventDefault();
		if (!isInteracting) return;

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
		handleInteractionEnd();
	}

	function handleTouchCancel(event: TouchEvent) {
		event.preventDefault();
		handleInteractionCancel();
	}

	// Mouse event handlers (renamed from the originals)
	function handleMouseDown(rowIndex: number, colIndex: number) {
		handleInteractionStart(rowIndex, colIndex);
	}

	function handleMouseUp() {
		handleInteractionEnd();
	}

	function handleMouseEnter(rowIndex: number, colIndex: number) {
		handleInteractionMove(rowIndex, colIndex);
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

	function animatedSelect(position: Position) {
		const cell = document.getElementById(`${position.row}${position.col}`);
		if (cell) {
			animate(cell, {
				scale: [1, 0.8, 1.1, 0.8, 1],
				opacity: [1, 0.8, 0.8, 0.8, 1],
				backgroundColor: [currentColor.isSelectedColorHex],
				duration: 1,
				easing: 'easeInOutQuad'
			});
		}
	}

	function animatedDeselect(position: Position) {
		const id = `${position.row}${position.col}`;
		const cell = document.getElementById(id);
		if (cell) {
			animate(cell, {
				scale: [1, 1.1, 1],
				opacity: [1, 0.8, 1],
				backgroundColor: discoveredColorMapping[id] ?? '#ffffff',
				duration: 1,
				easing: 'easeInOutQuad'
			});
		}
	}

	function resetSelectedCells() {
		updateSelectedCells([]);
	}

	function animateWrongWord(positions: Position[]) {
		positions.forEach((position) => {
			const cell = document.getElementById(`${position.row}${position.col}`);
			if (cell) {
				const backgroundColor =
					discoveredColorMapping[`${position.row}${position.col}`] ?? '#ffffff';
				animate(cell, {
					rotate: [-5, +5, -5, +5, -5, 0],
					duration: 300,
					easing: 'easeInOutQuad',
					backgroundColor: backgroundColor
				});
			}
		});
	}

	function animateDiscovered(positions: Position[]) {
		const colorTheme = currentColor;
		isAnimatingIsDiscovered = true;
		animate(
			positions.map((position) => {
				return document.getElementById(`${position.row}${position.col}`);
			}),
			{
				scale: [1, 0.8, 1.1, 0.8, 1],
				opacity: [1, 0.8, 0.8, 0.8, 1],
				duration: 500,
				backgroundColor: [colorTheme.isSelectedColorHex, colorTheme.bgHex],
				easing: 'easeInOutQuad',
				repeat: 1,
				onComplete: (animation) => {
					isAnimatingIsDiscovered = false;
				}
			}
		);
	}

	$effect(() => {
		isAnimatingIsDiscovered = true;
		let angle = isRotated ? 180 : 0;
		let elements = [];
		const board = document.getElementById('board');
		if (board) {
			elements.push(board);
		}
		const cells = Array.from(board?.children || []);
		elements.push(...cells);
		animate(elements, {
			rotate: [angle, angle],
			onComplete: () => {
				isAnimatingIsDiscovered = false;
			}
		});
	});

	function animatedHint(position: Position) {
		const cell = document.getElementById(`${position.row}${position.col}`);
		if (cell) {
			const colorTheme = currentColor;
			const backgroundColor = '#ffffff';
			animate(cell, {
				// scale: [1, 0.8, 1.1, 0.8, 1],
				rotate: [0, -5, +5, -5, +5, -5, +5, 0],
				duration: 1000,
				backgroundColor: [backgroundColor, colorTheme.hintHex, colorTheme.hintHex],
				easing: 'easeInOutQuad',
				delay: 900
				// onComplete: (animation) => {
				// 	animation.target.style.backgroundColor = currentColor.isDiscoveredColorHex;
				// }
			});
		}
	}

	$effect(() => {
		previousHints
			.filter((position) => {
				const shouldAnimate =
					!isAnimatingIsDiscovered && !discoveredColorMapping[`${position.row}${position.col}`];
				console.log(
					'🎥🎥🎥 shouldAnimate',
					isAnimatingIsDiscovered,
					discoveredColorMapping[`${position.row}${position.col}`],
					shouldAnimate
				);
				if (!isAnimatingIsDiscovered) {
					return true;
				}
				return shouldAnimate;
			})
			.forEach(animatedDeselect);
		hintPositions.forEach(animatedHint);
		previousHints = [...hintPositions];
	});
</script>

<div class="flex flex-col items-center justify-center">
	{#if isGameEnded}
		<div class="absolute top-1/2 left-1/2 z-10 -translate-x-1/2 -translate-y-1/2">
			<Confetti amount={confettiConfig.amount} size={confettiConfig.size} />
		</div>
	{/if}
	<div
		id="board"
		class=" grid rounded-md bg-white p-2 shadow-sm transition-transform duration-500 ease-in-out"
		style="grid-template-columns: repeat({numColumns}, minmax(0, 1fr));"
		onmouseleave={handleMouseLeave}
		onmouseup={handleMouseUp}
		ontouchend={handleTouchEnd}
		ontouchcancel={handleTouchCancel}
		ontouchmove={handleTouchMove}
		role="grid"
		tabindex="0"
	>
		{#each cells as row}
			{#each row as cell}
				<div class="h-[34px] w-[34px]">
					<div
						id={`${cell.row}${cell.col}`}
						class=" flex h-[30px] w-[30px] items-center justify-center rounded-md text-center text-[18px] font-semibold text-gray-900"
						onmousedown={() => handleMouseDown(cell.row, cell.col)}
						onmouseenter={() => handleMouseEnter(cell.row, cell.col)}
						ontouchstart={(e) => handleTouchStart(e, cell.row, cell.col)}
						ontouchend={handleTouchEnd}
						data-row={cell.row}
						data-col={cell.col}
						role="button"
						tabindex="0"
					>
						{cell.letter}
					</div>
				</div>
			{/each}
		{/each}
	</div>
</div>
