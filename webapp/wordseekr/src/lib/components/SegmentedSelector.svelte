<script lang="ts">
	import { onMount } from 'svelte';

	interface SegmentedSelectorProps {
		segments: string[];
		firstSelectedIndex: number | null;
		onChange: (index: number) => void;
	}

	let { segments, firstSelectedIndex, onChange }: SegmentedSelectorProps = $props();

	let selected = $state(firstSelectedIndex ?? 0);
	// References to DOM elements
	let containerElement: HTMLElement;
	let buttonsContainer: HTMLElement;
	let activeIndicator: HTMLElement;

	let selectedIndex = $derived(selected ? selected : 0);
	// Action to handle positioning the indicator
	function setupSegments(node: HTMLElement) {
		const resizeObserver = new ResizeObserver(() => updateIndicator());
		resizeObserver.observe(node);

		// Initial positioning
		updateIndicator();

		return {
			update: updateIndicator,
			destroy: () => resizeObserver.disconnect()
		};
	}

	// Handle selection change
	function select(index: number) {
		if (index !== selected) {
			selected = index;
			onChange(index);
		}
	}

	// Update the position and width of the active indicator
	function updateIndicator() {
		if (!containerElement || !buttonsContainer || selectedIndex < 0 || !segments.length) return;

		const buttons = Array.from(buttonsContainer.children) as HTMLElement[];
		if (buttons.length <= selectedIndex) return;

		const selectedButton = buttons[selectedIndex];
		if (!selectedButton) return;

		// Set width and position using transforms (more performant)
		activeIndicator.style.width = `${selectedButton.offsetWidth}px`;

		// Calculate the left position
		let leftPosition = 0;
		for (let i = 0; i < selectedIndex; i++) {
			leftPosition += buttons[i].offsetWidth;
		}
		activeIndicator.style.transform = `translateX(${leftPosition}px)`;
	}

	// Update indicator whenever selection changes
	$effect(() => {
		if (containerElement && selectedIndex >= 0) {
			updateIndicator();
		}
	});
</script>

<div
	class="relative flex h-8 w-full min-w-full rounded-lg bg-gray-200 p-0.5 font-sans"
	bind:this={containerElement}
	use:setupSegments
>
	<div
		bind:this={activeIndicator}
		class="absolute top-0.5 z-0 h-[calc(100%-4px)] rounded-[7px] bg-white shadow-sm transition-all duration-250 ease-[cubic-bezier(0.4,0,0.2,1)]"
	></div>
	<div bind:this={buttonsContainer} class="relative z-10 flex w-full">
		{#each segments as segment, i}
			<div class="flex min-w-18 flex-row items-center justify-center">
				<button
					onclick={() => select(i)}
					class="flex-1 cursor-pointer border-none bg-transparent text-xs transition-colors duration-200 ease-in-out
					{selectedIndex === i ? 'text-black ' : 'text-black/70'}
					{selected === i ? 'font-bold' : 'font-normal'}"
				>
					{segment}
				</button>
				{#if i !== segments.length - 1 && selectedIndex - 1 !== i && selectedIndex !== i}
					<div class="-ml-0.5 h-3/5 w-[1px] bg-gray-300"></div>
				{/if}
			</div>
		{/each}
	</div>
</div>
