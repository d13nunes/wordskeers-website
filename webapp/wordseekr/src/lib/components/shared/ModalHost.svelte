<script lang="ts">
	import { modal, closeModal } from '$lib/components/shared/ModalHost';
	import { fade, scale } from 'svelte/transition';

	const dynamicComponent = $derived($modal.component);
</script>

{#if $modal.isOpen}
	<div
		class="fixed inset-0 z-250 flex items-center justify-center bg-black/50"
		on:click={closeModal}
		in:fade={{ duration: 150, delay: 100 }}
		out:fade={{ duration: 150, delay: 100 }}
	>
		<div
			class=" m-4 max-h-[80%] w-full max-w-md overflow-y-auto rounded-2xl bg-white p-2 shadow-lg"
			on:click|stopPropagation
			in:scale={{ duration: 200 }}
			out:scale={{ duration: 150 }}
		>
			<svelte:component this={dynamicComponent} {...$modal.props} />
		</div>
	</div>
{/if}
