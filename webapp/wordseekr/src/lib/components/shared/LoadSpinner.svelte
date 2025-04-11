<script>
	import { Jumper } from 'svelte-loading-spinners';
	import { fade } from 'svelte/transition';
</script>

<div
	class="absolute top-0 right-0 bottom-0 left-0 flex h-full w-full items-center justify-center bg-white/50"
	in:fade={{ duration: 200 }}
	out:fade={{ duration: 150 }}
>
	<Jumper color="blue" />
</div>
