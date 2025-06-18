<script>
	import WecolmeModal from '$lib/components/Levels/WecolmeModal.svelte';
</script>

<div class="flex h-screen w-screen items-center justify-center bg-slate-50">
	<WecolmeModal
		onGiveReward={() => {
			console.log('!!! onGiveReward');
		}}
		onCoinAnimationCompleted={() => {
			console.log('!!! onCoinAnimationCompleted');
		}}
	/>
</div>
