<script lang="ts">
	import { type Position } from './Position';
	import { PathValidator } from './PathValidator';
	import type { ColorTheme } from './color-generator';
	interface Cell {
		letter: string;
		row: number;
		col: number;
		isSelected: boolean;
		isDiscovered: boolean;
		isDiscoveredColor: string | null;
	}

	let currentHintPositions: Position[] = [];
	interface Props {
		grid: string[][];
		isRotated: boolean;
		hintPositions: Position[];
		onWordSelect: (
			word: string,
			path: Position[],
			setDiscovered: (position: Position[]) => void
		) => void;

		getColor: () => ColorTheme;
	}
	let selectedCells: Position[] = $state([]);
	let firstSelectedCell: Position | null = null;
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
	let hintColor: string = 'bg-yellow-300';

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
			onWordSelect(selectedWord, cells, setDiscovered);
			resetSelectedCells();
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
			return currentColor.bg;
		}
		const isHint = hintPositions.some(
			(position) => position.row === cell.row && position.col === cell.col
		);
		if (isHint) {
			return 'bg-yellow-100';
		}
		if (cell.isDiscoveredColor) {
			return `${cell.isDiscoveredColor}`;
		}
		return '';
	}
</script>

<div class="flex flex-col items-center justify-center">
	<div
		class=" grid rounded-md bg-white p-2 shadow-sm transition-transform duration-500 ease-in-out"
		style="grid-template-columns: repeat({numColumns}, minmax(0, 1fr)); transform: {isRotated
			? 'rotate(180deg)'
			: 'rotate(0deg)'}"
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
						class=" flex h-[30px] w-[30px] items-center justify-center rounded-md text-[18px] font-semibold transition-colors
					duration-150 ease-in-out {getBGColor(cell)} text-center text-gray-900"
						style="transform: {isRotated ? 'rotate(180deg)' : 'rotate(0deg)'}"
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
