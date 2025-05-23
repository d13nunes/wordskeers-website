<script lang="ts">
	// No specific Svelte logic needed for this layout example
</script>

<div class="bg-gray-100 p-4">
	<h1 class="mb-4 text-center text-2xl font-bold">Special Grid Layout</h1>

	<div class="grid h-96 grid-cols-2 grid-rows-2 gap-4 border border-gray-300 p-2">
		<div class="flex flex-col items-center justify-center rounded bg-blue-500 p-4 text-white">
			<p class="font-semibold">Column 1, Row 1</p>
			<p>(50% Height)</p>
		</div>

		<div
			class="col-start-2 row-span-2 flex flex-col items-center justify-center rounded bg-green-600 p-4 text-white"
		>
			<p class="font-semibold">Column 2, Single Row</p>
			<p>(100% Height - Spans 2 Rows)</p>
		</div>

		<div class="flex flex-col items-center justify-center rounded bg-blue-700 p-4 text-white">
			<p class="font-semibold">Column 1, Row 2</p>
			<p>(50% Height)</p>
		</div>
	</div>

	<h2 class="mt-8 mb-4 text-center text-xl font-bold">Alternative DOM order (more intuitive)</h2>
	<div
		class="grid h-96 gap-4 border border-gray-300 bg-red-500 p-2
    portrait:grid-cols-1 portrait:grid-rows-3
    landscape:grid-cols-2 landscape:grid-rows-2
    "
	>
		<div
			class="flex h-full flex-col items-center justify-center rounded bg-sky-500 p-4
            text-white
            portrait:col-start-1 portrait:row-span-1 portrait:row-start-1
            landscape:col-start-1 landscape:row-span-1 landscape:row-start-1"
		>
			<p class="font-semibold">A Column 1, Row 1</p>
			<p>(50% Height)</p>
		</div>

		<div
			class="col-start-1 row-start-2 flex flex-col items-center justify-center rounded bg-sky-700 p-4 text-white
            portrait:col-start-1 portrait:row-span-1 portrait:row-start-2
            landscape:col-start-1 landscape:row-span-1 landscape:row-start-2"
		>
			<p class="font-semibold">C Column 1, Row 2</p>
			<p>(50% Height)</p>
		</div>

		<div
			class="flex flex-col items-center justify-center rounded bg-teal-600 p-4 text-white
            portrait:col-start-1 portrait:row-span-1 portrait:row-start-1
            landscape:col-start-2 landscape:row-span-2 landscape:row-start-1"
		>
			<p class="font-semibold">B Column 2, Single Row</p>
			<p>(100% Height - Spans 2 Rows)</p>
		</div>
	</div>
</div>

<style>
	/* No additional global CSS needed for this specific layout with Tailwind */
</style>
