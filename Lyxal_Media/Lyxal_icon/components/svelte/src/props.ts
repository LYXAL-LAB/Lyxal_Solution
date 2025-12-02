import type { LyxalIcon } from '@lyxal-icon/types';
import type { LyxalIconCustomisations as RawLyxalIconCustomisations } from '@lyxal-icon/utils/lib/customisations/defaults';
import { defaultIconCustomisations } from '@lyxal-icon/utils/lib/customisations/defaults';

/**
 * Icon render mode
 *
 * 'style' = 'bg' or 'mask', depending on icon content
 * 'bg' = <span> with style using `background`
 * 'mask' = <span> with style using `mask`
 * 'svg' = <svg>
 */
export type LyxalRenderMode = 'style' | 'bg' | 'mask' | 'svg';

/**
 * Icon customisations
 */
export type LyxalIconCustomisations = RawLyxalIconCustomisations & {
	// Allow rotation to be string
	rotate?: string | number;

	// Inline mode
	inline?: boolean;
};

export const defaultExtendedIconCustomisations = {
	...defaultIconCustomisations,
	inline: false,
};

/**
 * Icon properties
 */
export interface LyxalIconProps extends LyxalIconCustomisations {
	// Icon object
	icon: LyxalIcon | string;

	// Render mode
	mode?: LyxalRenderMode;

	// Style
	color?: string;

	// Flip shorthand
	flip?: string;
}

/**
 * Properties for element that are mentioned in render.ts
 */
interface LyxalElementProps {
	// Unique id, used as base for ids for shapes. Use it to get consistent ids for server side rendering
	id?: string;

	// Style
	style?: string;
}

/**
 * Mix of icon properties and HTMLElement properties
 */
export type IconProps = LyxalElementProps & LyxalIconProps;
