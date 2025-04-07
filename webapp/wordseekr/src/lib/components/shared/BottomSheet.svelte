<script lang="ts">
	interface Props {
		visible: boolean;
		close: () => void;
	}

	let { visible, close }: Props = $props();

	let startY = 0;
	let offsetY = 0;
	let isDragging = false;
	let hasAnimated = false;
	let isDismissing = false;

	$effect(() => {
		if (!visible) {
			// Reset all states when sheet is hidden
			hasAnimated = false;
			isDismissing = false;
			offsetY = 0;
		}
	});

	function handleDismiss() {
		if (!isDismissing) {
			isDismissing = true;
			setTimeout(close, 300);
		}
	}

	function handlePointerDown(event) {
		startY = event.clientY;
		isDragging = true;
		window.addEventListener('pointermove', handlePointerMove);
		window.addEventListener('pointerup', handlePointerUp);
	}

	function handlePointerMove(event) {
		if (!isDragging) return;
		offsetY = event.clientY - startY;
		if (offsetY < 0) offsetY = 0;
	}

	function handlePointerUp() {
		isDragging = false;
		window.removeEventListener('pointermove', handlePointerMove);
		window.removeEventListener('pointerup', handlePointerUp);

		if (offsetY > 100) {
			handleDismiss();
		} else {
			offsetY = 0;
		}
	}
</script>

{#if visible}
	<div
		class="pointer-events-none fixed inset-0 z-50 flex items-end justify-center"
		on:click={handleDismiss}
	>
		<div
			class="pointer-events-auto max-h-[90vh] w-full touch-none rounded-t-2xl bg-white p-4 shadow-xl transition-all duration-300 ease-out"
			on:click|stopPropagation
			on:pointerdown={handlePointerDown}
			style="transform: translateY({offsetY}px); --current-y: {offsetY}px;"
			class:slide-up={visible && !hasAnimated && !isDismissing}
			class:slide-down={isDismissing}
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

	.slide-down {
		animation: slideDown 0.3s cubic-bezier(0.4, 0, 0.2, 1) forwards;
	}

	@keyframes slideUp {
		from {
			transform: translateY(100%);
		}
		to {
			transform: translateY(0);
		}
	}

	@keyframes slideDown {
		from {
			transform: translateY(var(--current-y, 0));
		}
		to {
			transform: translateY(100%);
		}
	}
</style>
