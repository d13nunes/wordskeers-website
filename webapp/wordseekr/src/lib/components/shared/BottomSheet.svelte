<script lang="ts">
	interface Props {
		visible: boolean;
		close: () => void;
	}

	let { visible, close }: Props = $props();

	let startY = $state(0);
	let offsetY = $state(0);
	let isDragging = $state(false);
	let hasAnimated = $state(false);
	let isDismissing = $state(false);
	let currentY = $state(0);

	$effect(() => {
		if (!visible) {
			// Reset all states when sheet is hidden
			hasAnimated = false;
			isDismissing = false;
			offsetY = 0;
			currentY = 0;
		}
	});

	function handleDismiss() {
		if (!isDismissing) {
			currentY = offsetY;
			isDismissing = true;
			setTimeout(close, 300);
		}
	}

	function handlePointerDown(event: PointerEvent) {
		startY = event.clientY;
		isDragging = true;
		document.addEventListener('pointermove', handlePointerMove);
		document.addEventListener('pointerup', handlePointerUp);
	}

	function handlePointerMove(event: PointerEvent) {
		if (!isDragging) return;
		offsetY = event.clientY - startY;
		if (offsetY < 0) offsetY = 0;
	}

	function handlePointerUp() {
		isDragging = false;
		document.removeEventListener('pointermove', handlePointerMove);
		document.removeEventListener('pointerup', handlePointerUp);

		if (offsetY > 100) {
			handleDismiss();
		} else {
			offsetY = 0;
		}
	}
</script>

{#if visible}
	<div
		class="pointer-events-none fixed inset-0 z-150 flex items-end justify-center"
		on:click={handleDismiss}
	>
		<div
			class="shadow-top pointer-events-auto max-h-[90vh] w-full touch-none rounded-t-4xl bg-white p-4"
			on:click|stopPropagation
			on:pointerdown={handlePointerDown}
			class:slide-up={visible && !hasAnimated && !isDismissing}
			class:dragging={isDragging}
			class:dismissing={isDismissing}
			style="transform: translateY({isDragging ? offsetY + 'px' : isDismissing ? '100%' : '0'});"
			on:animationend={() => {
				if (!isDismissing) {
					hasAnimated = true;
				}
			}}
		>
			<div
				class="mx-auto mb-4 h-1.5 w-10 cursor-pointer rounded-full bg-gray-300"
				on:click={handleDismiss}
			/>
			<slot />
		</div>
	</div>
{/if}

<style>
	.slide-up {
		animation: slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1) forwards;
	}

	.dragging {
		transition: none !important;
	}

	.dismissing {
		transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.shadow-top {
		box-shadow:
			0 -4px 6px -1px rgb(0 0 0 / 0.1),
			0 -2px 4px -2px rgb(0 0 0 / 0.1);
	}

	@keyframes slideUp {
		from {
			transform: translateY(100%);
		}
		to {
			transform: translateY(0);
		}
	}
</style>
