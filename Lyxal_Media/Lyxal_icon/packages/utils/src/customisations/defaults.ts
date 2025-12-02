import type { LyxalTransformations } from '@lyxal-icon/types';
import { defaultIconTransformations } from '../icon/defaults';

/**
 * Icon size
 */
export type LyxalIconSize = null | string | number;

/**
 * Dimensions
 */
export interface LyxalIconSizeCustomisations {
	width?: LyxalIconSize;
	height?: LyxalIconSize;
}

/**
 * Icon customisations
 */
export interface LyxalIconCustomisations
	extends LyxalTransformations,
		LyxalIconSizeCustomisations {}

export type FullIconCustomisations = Required<LyxalIconCustomisations>;

/**
 * Default icon customisations values
 */
export const defaultIconSizeCustomisations: Required<LyxalIconSizeCustomisations> =
	Object.freeze({
		width: null,
		height: null,
	});

export const defaultIconCustomisations: FullIconCustomisations = Object.freeze({
	// Dimensions
	...defaultIconSizeCustomisations,

	// Transformations
	...defaultIconTransformations,
});
