import {
	DirectionName,
	getDirection,
	allDirectionNames,
	allDirections,
	type Direction
} from './Direction';
import { type Position } from './Position';

export class PathValidator {
	private allowedDirections: Direction[];

	constructor(allowedDirections: Set<DirectionName> = new Set(allDirectionNames)) {
		const allowedDirectionsArray = Array.from(allowedDirections);
		this.allowedDirections = allowedDirectionsArray
			.map((direction) => allDirections.find((d) => d.name === direction))
			.filter((direction) => direction !== undefined);
	}

	isValidPath(start: Position, end: Position): boolean {
		const dx = end.col - start.col;
		const dy = end.row - start.row;

		// Normalize to unit vector
		const magnitude = Math.max(Math.abs(dx), Math.abs(dy));
		if (magnitude <= 0) {
			return false;
		}

		const direction = getDirection(dx, dy);

		return this.allowedDirections.find((d) => d.name === direction) !== undefined;
	}

	getPositionsInPath(start: Position, end: Position): Position[] {
		if (!this.isValidPath(start, end)) {
			return [];
		}

		const snappedDirection = this.getSnappedDirection(start, end);
		const positions: Position[] = [];
		const dx = end.col - start.col;
		const dy = end.row - start.row;
		const steps = Math.max(Math.abs(dx), Math.abs(dy));

		if (steps <= 0) {
			return [start];
		}

		const dx1 = snappedDirection.direction.x;
		const dy1 = snappedDirection.direction.y;

		for (let index = 0; index <= steps; index++) {
			const row = start.row + index * dy1;
			const col = start.col + index * dx1;
			positions.push({ row, col });
		}

		return positions;
	}

	normalizeAngle(angle: number): number {
		return ((angle + 180) % 360) - 180;
	}

	getSnappedDirection(start: Position, end: Position) {
		const dx = end.col - start.col;
		const dy = end.row - start.row;

		if (dx === 0 && dy === 0) {
			throw new Error('Start and end points are the same — no direction.');
		}

		// Calculate the angle between the points
		const angleRad = Math.atan2(dy, dx);
		const angleDeg = angleRad * (180 / Math.PI);

		// Find the closest direction by comparing angles
		let closest = allDirections[0];
		let minDiff = Infinity;

		for (const dir of allDirections) {
			const diff = Math.abs(this.normalizeAngle(angleDeg - dir.angle));
			// console.log('📺 angleDegdiff', dir.name, dir.angle, diff);
			if (diff < minDiff) {
				minDiff = diff;
				closest = dir;
			}
		}

		return {
			direction: {
				x: closest.dx,
				y: closest.dy
			},
			name: closest.name
		};
	}
}
