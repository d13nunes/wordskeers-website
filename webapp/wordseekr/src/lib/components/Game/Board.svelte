<script lang="ts">
	import { type Position } from './Position';
	import { PathValidator } from './PathValidator';
	import type { ColorTheme } from './color-generator';
	import Confetti from 'svelte-confetti';

	interface Cell {
		letter: string;
		row: number;
		col: number;
		isSelected: boolean;
		isDiscovered: boolean;
		isDiscoveredColor: string | null;
	}
	interface Props {
		grid: string[][];
		isRotated: boolean;
		hintPositions: Position[];
		onWordSelect: (
			word: string,
			path: Position[],
			setDiscovered: (position: Position[]) => void
		) => boolean;
		getColor: () => ColorTheme;
	}
	let selectedCells: Position[] = $state([]);
	let firstSelectedCell: Position | null = null;
	let showConfetti = $state(false);
	let confettiConfig = $state({ amount: 200, size: 20 });
	// let discoveredCells: Set<Position> = new Set();
	let pathValidator = new PathValidator();
	let { grid, onWordSelect, getColor, isRotated = false, hintPositions = [] }: Props = $props();

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

	function handleInteractionStart(rowIndex: number, colIndex: number) {
		isInteracting = true;
		currentColor = getColor();
		const newCell = { row: rowIndex, col: colIndex };
		updateSelectedCells([newCell]);
		cells[rowIndex][colIndex].isSelected = true;
		firstSelectedCell = newCell;
	}

	const defaultColor = 'bg-red-100';

	function setDiscovered(position: Position[]) {
		position.forEach((pos) => {
			cells[pos.row][pos.col].isDiscovered = true;
			cells[pos.row][pos.col].isDiscoveredColor = currentColor?.bg ?? defaultColor;
		});

		// Calculate confetti amount based on word length
		const wordLength = position.length;
		confettiConfig = {
			amount: Math.min(50 + wordLength * 30, 300), // More confetti for longer words, max 300
			size: Math.min(15 + wordLength * 2, 30) // Bigger confetti for longer words, max 30
		};

		setTimeout(() => {
			showConfetti = true;
		}, 500);
		setTimeout(() => {
			showConfetti = false;
		}, 1500);
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
			const didFoundWord = onWordSelect(selectedWord, cells, setDiscovered);
			if (didFoundWord) {
				resetSelectedCells();
				currentColor = getColor();
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
			cells[position.row][position.col].isSelected = false;
		});
		newCells.forEach((position) => {
			cells[position.row][position.col].isSelected = true;
		});
		selectedCells.length = 0;
		selectedCells.push(...newCells);
	}

	function resetSelectedCells() {
		updateSelectedCells([]);
	}
	function getBGColor(cell: Cell) {
		if (cell.isSelected) {
			return currentColor.isSelectedColor;
		}
		const isHint = hintPositions.some(
			(position) => position && position.row === cell.row && position.col === cell.col
		);
		if (isHint) {
			return currentColor.hint;
		}
		if (cell.isDiscoveredColor) {
			console.log('✅ cell.isDiscoveredColor', cell.isDiscoveredColor);
			return `${cell.isDiscoveredColor}`;
		}
		return '';
	}

	let boardAngle = $derived(isRotated ? 'rotate(180deg)' : 'rotate(0deg)');
</script>

<div class="flex flex-col items-center justify-center">
	{#if showConfetti}
		<div class="absolute top-1/2 left-1/2 z-10 -translate-x-1/2 -translate-y-1/2">
			<Confetti amount={confettiConfig.amount} size={confettiConfig.size} />
		</div>
	{/if}
	<div
		class=" grid rounded-md bg-white p-2 shadow-sm transition-transform duration-500 ease-in-out"
		style="grid-template-columns: repeat({numColumns}, minmax(0, 1fr)); transform: {boardAngle}"
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
				<div class="h-[32px] w-[32px]">
					<div
						id={`${cell.row}${cell.col}`}
						style="transform: {boardAngle}"
						class=" flex h-[30px] w-[30px] items-center justify-center rounded-md text-[18px] font-semibold {getBGColor(
							cell
						)} text-center text-gray-900 {cell.isDiscovered ? 'discovered' : ''}"
						onmousedown={() => handleMouseDown(cell.row, cell.col)}
						onmouseenter={() => handleMouseEnter(cell.row, cell.col)}
						ontouchstart={(e) => handleTouchStart(e, cell.row, cell.col)}
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

<style>
	@keyframes discover {
		/* 0% {
			transform: scale(0.8);
			opacity: 1;
		}
		25% {
			transform: scale(1.2);
			opacity: 0.8;
		}
		50% {
			transform: scale(0.9);
			opacity: 1.8;
		}
		75% {
			transform: scale(1.1);
			opacity: 0.8;
		}
		100% {
			transform: scale(1);
			opacity: 1;
		} */

		0% {
			transform: scale(0.8);
			opacity: 1;
		}
		50% {
			transform: scale(1.2);
			opacity: 0.8;
		}
		100% {
			transform: scale(1);
			opacity: 1;
		}
	}

	.discovered {
		animation: discover 0.5s ease-out;
	}
</style>
