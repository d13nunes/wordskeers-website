import { DirectionName, directionMap, type Direction } from '../components/Game/Direction';

const getDirections = (names: DirectionName[]): Direction[] => {
	return names.map((name) => Object.values(directionMap).find((d) => d.name === name)!);
};

export const DirectionPresets = {
	veryEasy: getDirections([DirectionName.RIGHT, DirectionName.DOWN]),
	easy: getDirections([DirectionName.RIGHT, DirectionName.DOWN, DirectionName.DOWN_RIGHT]),
	medium: getDirections([
		DirectionName.RIGHT,
		DirectionName.DOWN,
		DirectionName.DOWN_RIGHT,
		DirectionName.DOWN_LEFT
	]),
	hard: getDirections([
		DirectionName.RIGHT,
		DirectionName.DOWN,
		DirectionName.DOWN_RIGHT,
		DirectionName.DOWN_LEFT,
		DirectionName.UP_RIGHT,
		DirectionName.UP_LEFT
	]),
	veryHard: getDirections([
		DirectionName.RIGHT,
		DirectionName.DOWN,
		DirectionName.DOWN_RIGHT,
		DirectionName.DOWN_LEFT,
		DirectionName.UP_RIGHT,
		DirectionName.UP_LEFT,
		DirectionName.UP,
		DirectionName.LEFT
	])
};
