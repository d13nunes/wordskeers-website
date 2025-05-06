export interface Direction {
	name: DirectionName;
	dx: number;
	dy: number;
	angle: number;
}

export enum DirectionName {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT
}

export const allDirectionNames = [
	DirectionName.UP,
	DirectionName.DOWN,
	DirectionName.LEFT,
	DirectionName.RIGHT,
	DirectionName.UP_LEFT,
	DirectionName.UP_RIGHT,
	DirectionName.DOWN_LEFT,
	DirectionName.DOWN_RIGHT
];

export const directionMap: Record<string, Direction> = {
	UP: {
		name: DirectionName.UP,
		dx: 0,
		dy: -1,
		angle: 0
	},
	DOWN: {
		name: DirectionName.DOWN,
		dx: 0,
		dy: 1,
		angle: 180
	},
	LEFT: {
		name: DirectionName.LEFT,
		dx: -1,
		dy: 0,
		angle: 270
	},
	RIGHT: {
		name: DirectionName.RIGHT,
		dx: 1,
		dy: 0,
		angle: 90
	},
	UP_LEFT: {
		name: DirectionName.UP_LEFT,
		dx: -1,
		dy: -1,
		angle: 315
	},
	UP_RIGHT: {
		name: DirectionName.UP_RIGHT,
		dx: 1,
		dy: -1,
		angle: 45
	},
	DOWN_LEFT: {
		name: DirectionName.DOWN_LEFT,
		dx: -1,
		dy: 1,
		angle: 225
	},
	DOWN_RIGHT: {
		name: DirectionName.DOWN_RIGHT,
		dx: 1,
		dy: 1,
		angle: 135
	}
};

export const allDirections: Direction[] = Object.values(directionMap);

export function getDirection(dx: number, dy: number): DirectionName {
	// Normalize to unit vector or zero
	const absDx = Math.abs(dx);
	const absDy = Math.abs(dy);
	const magnitude = Math.max(absDx, absDy);

	if (magnitude === 0) {
		throw new Error('Cannot determine direction from zero movement');
	}

	const unitDx = dx / magnitude;
	const unitDy = dy / magnitude;

	// Check horizontal and vertical
	if (unitDx === 0 && unitDy < 0) {
		return DirectionName.UP;
	}
	if (unitDx === 0 && unitDy > 0) {
		return DirectionName.DOWN;
	}
	if (unitDx < 0 && unitDy === 0) {
		return DirectionName.LEFT;
	}
	if (unitDx > 0 && unitDy === 0) {
		return DirectionName.RIGHT;
	}

	// Check diagonals
	if (unitDx < 0 && unitDy < 0) {
		return DirectionName.UP_LEFT;
	}
	if (unitDx > 0 && unitDy < 0) {
		return DirectionName.UP_RIGHT;
	}
	if (unitDx < 0 && unitDy > 0) {
		return DirectionName.DOWN_LEFT;
	}
	if (unitDx > 0 && unitDy > 0) {
		return DirectionName.DOWN_RIGHT;
	}

	throw new Error('Unexpected direction calculation');
}
