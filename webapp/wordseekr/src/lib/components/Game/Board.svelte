<script lang="ts">
	import { type Position } from './Position';
	import { PathValidator } from './PathValidator';
	import type { ColorTheme } from './color-generator';
	import { animate } from 'animejs';
	import { getPositionId } from '$lib/utils/string-utils';
	import { onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';

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
		onWordSelect: (word: string, path: Position[], letterSize: number) => Position[];
		getColor: () => ColorTheme;
		class?: string;
	}

	// Add some constraints to prevent cells from getting too small or too large

	const minFactor = 0.6;
	const maxFactor = getIsSmallScreen() ? 2 : 1.4;

	let discoveredColorMapping: Record<string, string> = $state({});
	let selectedCells: Position[] = $state([]);
	let firstSelectedCell: Position | null = null;
	let isAnimatingIsDiscovered = false;
	let pathValidator = new PathValidator();
	let {
		grid,
		onWordSelect,
		getColor,
		isRotated = false,
		hintPositions = [],
		isGameEnded = false,
		class: classProp = ''
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
	const defaultColor = '#FEE2E2';

	$effect(() => {
		currentColor = getColor();
	});

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
					setDiscovered(discoveredPositions);
					animateDiscovered(discoveredPositions);
					resetSelectedCells();
					currentColor = getColor();
				} else {
					animateWrongWord(cells);
				}
			} catch (error) {
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
		isInteracting = false;
		resetSelectedCells();
	}

	// Touch event handlers
	function handleTouchStart(event: TouchEvent, rowIndex: number, colIndex: number) {
		event.preventDefault();
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

	function resetSelectedCells() {
		updateSelectedCells([]);
	}

	function animatedSelect(position: Position) {
		const cell = document.getElementById(getPositionId(position.row, position.col));
		if (cell) {
			animate(cell, {
				// scale: [1, 0.8, 1.1, 0.8, 1],
				// opacity: [1, 0.8, 0.8, 0.8, 1],
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
				// scale: [1, 0.8, 1.1, 0.8, 1],
				rotate: [0, -5, +5, -5, +5, -5, +5, 0],
				duration: 1000,
				backgroundColor: [backgroundColor, colorTheme.hintHex, colorTheme.hintHex],
				ease: 'inOutQuad',
				delay: 900
				// onComplete: (animation) => {
				// 	animation.target.style.backgroundColor = currentColor.isDiscoveredColorHex;
				// }
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
					onComplete: (animation) => {
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
		letterSize: 30,
		fontSize: 20
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

	function fixBoardRotation() {
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

			onComplete: () => {}
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

		// Initial fade-in animation
		animate(boardElement, {
			opacity: [0, 1],
			duration: 500,
			ease: 'inOutQuad'
		});

		return () => {
			if (resizeTimeout) {
				window.cancelAnimationFrame(resizeTimeout);
			}
			resizeObserver.disconnect();
		};
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
			fixBoardRotation();
		}
	});
</script>

<div bind:this={boardElement} class="flex w-full flex-col items-center justify-center {classProp}">
	<div
		id="board"
		class="grid rounded-md bg-white p-2 shadow-sm transition-all ease-in-out"
		style="
			grid-template-columns: repeat({numColumns}, minmax(0, 1fr));
			--square-size: {squareSize}px;
			--letter-size: {letterSize}px;
			--font-size: {fontSize}px;
		"
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
