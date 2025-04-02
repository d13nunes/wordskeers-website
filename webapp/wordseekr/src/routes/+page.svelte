<script lang="ts">
	import Tag from '$lib/components/Tag.svelte';
	import RotatePowerUp from '$lib/components/PowerUps/RotatePowerUp.svelte';
	import DirectionPowerUp from '$lib/components/PowerUps/DirectionPowerUp.svelte';
	import FindLetterPowerUp from '$lib/components/PowerUps/FindLetterPowerUp.svelte';
	import FindWordPowerUp from '$lib/components/PowerUps/FindWordPowerUp.svelte';
	import PauseButton from '$lib/components/Pause/PauseButton.svelte';

	import { goto } from '$app/navigation';
	function onPowerUpClick() {
		console.log('!!!! clicked on powerUp');
	}
	function onPauseClick() {
		console.log('!!!! clicked on pause');
		/// show new game route
		goto('/newgame');
	}
</script>

<div class="bg-slate-50">
	<div class="p-8">
		<div class="card flex flex-row flex-wrap gap-2">
			<Tag tag="Hello" isDiscovered={true} />
			<Tag tag="Hello World" variant="red" />
			<Tag tag="Hello World 1" variant="cyan" />
			<Tag tag="Hello World 2" variant="emerald" />
			<Tag tag="Hello World 3" variant="amber" />
			<Tag tag="Hello" isDiscovered={true} />
			<Tag tag="Hello World" variant="red" />
			<Tag tag="Hello World 1" variant="cyan" />
			<Tag tag="Hello World 2" variant="emerald" />
			<Tag tag="Hello World 3" variant="amber" />
			<Tag tag="Hello" isDiscovered={true} />
			<Tag tag="Hello World" variant="red" />
			<Tag tag="Hello World 1" variant="cyan" />
			<Tag tag="Hello World 2" variant="emerald" />
			<Tag tag="Hello World 3" variant="amber" />
			<Tag tag="Hello" isDiscovered={true} />
			<Tag tag="Hello World" variant="red" />
			<Tag tag="Hello World 1" variant="cyan" />
			<Tag tag="Hello World 2" variant="emerald" />
			<Tag tag="Hello World 3" variant="amber" />
		</div>
	</div>
	<div class="flex flex-row gap-2 p-8">
		<PauseButton onClick={onPauseClick} />
		<div class="w-full"></div>
		<RotatePowerUp onClick={onPowerUpClick} />
		<DirectionPowerUp onClick={onPowerUpClick} />
		<FindLetterPowerUp onClick={onPowerUpClick} />
		<FindWordPowerUp onClick={onPowerUpClick} />
	</div>
</div>
