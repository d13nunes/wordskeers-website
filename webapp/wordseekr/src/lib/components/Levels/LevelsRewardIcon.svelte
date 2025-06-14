<script lang="ts">
	interface Props {
		fill: string;
	}

	const { fill }: Props = $props();
</script>

<svg xmlns="http://www.w3.org/2000/svg" {fill} viewBox="0 0 16 16">
	<g clip-path="url(#a)">
		<path fill="#fff" d="M1 7h14v2H1zM7 9h2v7H7z" />
		<path
			{fill}
			d="M5.95 2.15 7.05 4h-2.3a1.25 1.25 0 1 1 0-2.5h.07c.46 0 .9.25 1.13.65ZM2 2.75c0 .45.1.88.3 1.25H1a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1h-1.3a2.75 2.75 0 0 0-2.45-4h-.07c-1 0-1.92.53-2.43 1.39L8 2.67 7.25 1.4A2.82 2.82 0 0 0 4.82 0h-.07A2.75 2.75 0 0 0 2 2.75Zm10.5 0c0 .7-.56 1.25-1.25 1.25H8.96l1.09-1.85c.23-.4.67-.65 1.13-.65h.07c.7 0 1.25.56 1.25 1.25ZM1 9v5.5c0 .83.67 1.5 1.5 1.5H7V9H1Zm8 7h4.5c.83 0 1.5-.67 1.5-1.5V9H9v7Z"
		/></g
	><defs> <clipPath id="a"><path fill="#fff" d="M0 0h16v16H0V0Z" /></clipPath></defs>
</svg>
