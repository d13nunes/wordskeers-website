<script lang="ts">
	import { writable } from 'svelte/store';
	import { AdManager, AdType } from '$lib/ads/AdManager';
	import { MockAdProvider } from '$lib/ads/MockProvider';
	const adManager = new AdManager();

	adManager.registerProvider('mock', new MockAdProvider());
	type LogEntry = {
		timestamp: Date;
		message: string;
		type: 'info' | 'error' | 'success';
	};

	let selectedAdType: AdType = AdType.Rewarded;
	const adTypes: AdType[] = [
		AdType.Rewarded,
		AdType.Interstitial,
		AdType.Banner,
		AdType.RewardedInterstitial
	];
	const logs = writable<LogEntry[]>([]);

	function addLog(message: string, type: LogEntry['type'] = 'info') {
		logs.update((currentLogs) => [...currentLogs, { timestamp: new Date(), message, type }]);
		// Optional: Keep logs capped at a certain number
		// logs.update(l => l.slice(-100));
	}

	function showAd() {
		addLog(`Attempting to show ${selectedAdType} ad...`);
		// TODO: Implement actual ad showing logic for the selected type
		// This will likely involve calling an external Ad SDK
		addLog(`Placeholder: Show ${selectedAdType} ad function called.`, 'info');
		// Simulate potential outcomes
		setTimeout(() => {
			const success = Math.random() > 0.3; // Simulate success/failure
			if (success) {
				addLog(`${selectedAdType} ad shown successfully.`, 'success');
				if (selectedAdType === 'rewarded') {
					setTimeout(() => addLog('Reward granted!', 'success'), 1500);
				}
				setTimeout(() => addLog(`${selectedAdType} ad closed.`, 'info'), 3000);
			} else {
				addLog(`Failed to show ${selectedAdType} ad.`, 'error');
			}
		}, 1000);
	}

	function loadAd() {
		addLog(`Attempting to load ${selectedAdType} ad...`);
		// TODO: Implement actual ad loading logic
		addLog(`Placeholder: Load ${selectedAdType} ad function called.`, 'info');
		setTimeout(() => {
			const success = Math.random() > 0.2; // Simulate success/failure
			if (success) {
				addLog(`${selectedAdType} ad loaded successfully.`, 'success');
			} else {
				addLog(`Failed to load ${selectedAdType} ad.`, 'error');
			}
		}, 800);
	}

	// Reactive statement to clear logs when ad type changes
	$: {
		selectedAdType; // Trigger reactivity when selectedAdType changes
		logs.set([]); // Clear logs
		addLog(`Switched to ${selectedAdType} ad type.`);
	}
</script>

<svelte:head>
	<title>Ad Testing</title>
</svelte:head>

<div class="ad-tester-container">
	<h1>Ad Tester</h1>

	<div class="controls">
		<label for="adType">Select Ad Type:</label>
		<select id="adType" bind:value={selectedAdType}>
			{#each adTypes as type}
				<option value={type}>{type.charAt(0).toUpperCase() + type.slice(1)}</option>
			{/each}
		</select>

		<button on:click={loadAd} title="Preload the selected ad">Load Ad</button>
		<button on:click={showAd} title="Display the loaded ad">Show Ad</button>
	</div>

	<div class="logs">
		<h2>Logs</h2>
		{#if $logs.length === 0}
			<p>No logs yet.</p>
		{:else}
			<ul>
				{#each $logs as log (log.timestamp)}
					<li class={log.type}>
						[{log.timestamp.toLocaleTimeString()}] {log.message}
					</li>
				{/each}
			</ul>
		{/if}
	</div>
</div>

<style>
	.ad-tester-container {
		font-family: sans-serif;
		padding: 20px;
		max-width: 800px;
		margin: 0 auto;
	}

	.controls {
		margin-bottom: 20px;
		display: flex;
		gap: 10px;
		align-items: center;
	}

	label {
		margin-right: 5px;
	}

	select,
	button {
		padding: 8px 12px;
		border: 1px solid #ccc;
		border-radius: 4px;
		cursor: pointer;
	}

	button:hover {
		background-color: #f0f0f0;
	}

	button:active {
		background-color: #e0e0e0;
	}

	.logs {
		border: 1px solid #eee;
		padding: 15px;
		border-radius: 4px;
		background-color: #f9f9f9;
		height: 300px;
		overflow-y: auto;
	}

	.logs h2 {
		margin-top: 0;
		margin-bottom: 10px;
		font-size: 1.2em;
	}

	.logs ul {
		list-style-type: none;
		padding: 0;
		margin: 0;
	}

	.logs li {
		padding: 4px 0;
		border-bottom: 1px dotted #eee;
		font-size: 0.9em;
	}

	.logs li:last-child {
		border-bottom: none;
	}

	.logs .info {
		color: #333;
	}

	.logs .success {
		color: green;
		font-weight: bold;
	}

	.logs .error {
		color: red;
		font-weight: bold;
	}
</style>
