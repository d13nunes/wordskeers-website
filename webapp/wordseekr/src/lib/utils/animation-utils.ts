import { animate, JSAnimation } from 'animejs';

export function rotateIconAnimation(
	icon: HTMLDivElement,
	loop: boolean = true,
	delay: number = 2000,
	loopDelay: number = 5000,
	autoplay: boolean = false
): JSAnimation {
	return animate(icon, {
		rotate: [0, -15, +15, -15, +15, -15, 0],
		duration: 1000,
		easing: 'inOutQuad',
		loop: loop,
		loopDelay: loopDelay,
		delay: delay,
		autoplay: autoplay
	});
}
