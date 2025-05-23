<script lang="ts">
	import PauseButton from '$lib/components/Pause/PauseButton.svelte';
	import FindLetterPowerUp from '$lib/components/PowerUps/FindLetterPowerUp.svelte';
	import FindWordPowerUp from '$lib/components/PowerUps/FindWordPowerUp.svelte';
	import RotatePowerUp from '$lib/components/PowerUps/RotatePowerUp.svelte';

	interface Props {
		isFindWordDisabled: boolean;
		isFindLetterDisabled: boolean;
		isRotateDisabled: boolean;
		findWordIconId: string;
		findLetterIconId: string;
		rotateIconId: string;
		findWordPrice: string;
		findLetterPrice: string;
		rotatePrice: string;
		onPauseClick: () => void;
		onPowerUpFindWordClick: (iconId: string) => void;
		onPowerUpFindLetterClick: (iconId: string) => void;
		onPowerUpRotateClick: (iconId: string) => void;
	}

	const {
		isFindWordDisabled,
		isFindLetterDisabled,
		isRotateDisabled,
		findWordIconId,
		findLetterIconId,
		rotateIconId,
		findWordPrice,
		findLetterPrice,
		rotatePrice,
		onPauseClick,
		onPowerUpFindWordClick,
		onPowerUpFindLetterClick,
		onPowerUpRotateClick
	}: Props = $props();
</script>

<div class="flex flex-row items-center gap-6">
	<PauseButton onclick={onPauseClick} />
	<div class="flex w-full flex-row items-center justify-center gap-2">
		<FindWordPowerUp
			id={findWordIconId}
			onclick={() => onPowerUpFindWordClick(findWordIconId)}
			price={findWordPrice}
			disabled={isFindWordDisabled}
		/>
		<FindLetterPowerUp
			id={findLetterIconId}
			onclick={() => onPowerUpFindLetterClick(findLetterIconId)}
			price={findLetterPrice}
			disabled={isFindLetterDisabled}
		/>
		<RotatePowerUp
			id={rotateIconId}
			onclick={() => onPowerUpRotateClick(rotateIconId)}
			price={rotatePrice}
			disabled={isRotateDisabled}
		/>
	</div>
</div>
