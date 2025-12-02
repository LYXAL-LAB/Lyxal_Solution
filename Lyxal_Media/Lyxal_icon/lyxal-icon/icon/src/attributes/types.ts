import type { LyxalIcon } from '@lyxal-icon/types';

/**
 * SVG attributes that can be overwritten
 */
export interface LyxalIconSVGAttributes {
	preserveAspectRatio: string;
}

/**
 * Icon render modes
 *
 * 'bg' = SPAN with style using `background`
 * 'mask' = SPAN with style using `mask`
 * 'svg' = SVG
 */
export type ActualRenderMode = 'bg' | 'mask' | 'svg';

/**
 * Extra render modes
 *
 * 'style' = 'bg' or 'mask', depending on icon content
 */
export type LyxalRenderMode = 'style' | ActualRenderMode;

/**
 * Icon customisations
 */
export type LyxalIconCustomisationProperties = {
	// Dimensions
	width?: string | number;
	height?: string | number;

	// Transformations
	rotate?: string | number;
	flip?: string;
};

/**
 * All properties
 */
export interface LyxalIconProperties
	extends LyxalIconCustomisationProperties,
	Partial<LyxalIconSVGAttributes> {
	// Icon to render: name, object or serialised object
	icon: string | LyxalIcon;

	// Render mode
	mode?: LyxalRenderMode;

	// Inline mode
	inline?: boolean;

	// Do not use intersection observer
	noobserver?: boolean;
}

/**
 * Attributes as properties
 */
export interface LyxalIconAttributes
	extends Partial<
		Record<keyof Omit<LyxalIconProperties, 'icon' | 'mode'>, string>
	>,
	Partial<LyxalIconSVGAttributes> {
	// Icon to render: name or serialised object
	icon: string;

	// Render mode
	mode?: LyxalRenderMode;
}
