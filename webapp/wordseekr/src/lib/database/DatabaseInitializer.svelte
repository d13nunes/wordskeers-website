<!-- <script lang="ts">
	import { onMount } from 'svelte';
	import { databaseService, databaseState } from './database.service';
	import { goto } from '$app/navigation';

	let isInitializing = $state(false);
	let error: string | null = $state(null);

	let { children } = $props();

	onMount(async () => {
		try {
			// await databaseService.initialize();
		} catch (e) {
			console.error('!!! DatabaseInitializer error', e);
			error = e instanceof Error ? e.message : 'Failed to initialize database';
		} finally {
			isInitializing = false;
		}
	});

	$effect(() => {
		console.log('!!! DatabaseInitializer isInitializing', isInitializing);
		console.log('!!! DatabaseInitializer databaseState', $databaseState.error);
		error = $databaseState.error;
	});
</script>

{#if isInitializing}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="text-center">
			<div class="mx-auto h-12 w-12 animate-spin rounded-full border-b-2 border-gray-900"></div>
			<p class="mt-4 text-gray-700">Initializing database...</p>
		</div>
	</div>
{/if}

{#if error}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="mx-4 max-w-md rounded-lg border border-red-200 bg-red-50 p-4">
			<h3 class="text-lg font-medium text-red-800">Database Error</h3>
			<p class="mt-2 text-sm text-red-700">{error}</p>
			<button
				class="mt-4 rounded-md bg-red-100 px-4 py-2 text-red-700 transition-colors hover:bg-red-200"
				onclick={() => {
					goto('/');
				}}
			>
				Retry
			</button>
		</div>
	</div>
{/if}
{@render children()} -->
