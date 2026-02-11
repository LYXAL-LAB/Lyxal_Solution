import type {
	LyxalDimenisons,
	LyxalTransformations,
	LyxalOptional,
	LyxalIcon,
	ExtendedLyxalIcon,
} from '@lyxal-icon/types';

/** Export icon and full icon types */
export { LyxalIcon };

export type FullLyxalIcon = Required<LyxalIcon>;

/** Partial and full extended icon */
export type PartialExtendedLyxalIcon = Partial<ExtendedLyxalIcon>;

type LyxalIconExtraProps = Omit<ExtendedLyxalIcon, keyof LyxalIcon>;
export type FullExtendedLyxalIcon = FullLyxalIcon & LyxalIconExtraProps;

/** Default values for dimensions */
export const defaultIconDimensions: Required<LyxalDimenisons> = Object.freeze(
	{
		left: 0,
		top: 0,
		width: 16,
		height: 16,
	}
);

/** Default values for transformations */
export const defaultIconTransformations: Required<LyxalTransformations> =
	Object.freeze({
		rotate: 0,
		vFlip: false,
		hFlip: false,
	});

/** Default values for all optional LyxalIcon properties */
export const defaultIconProps: Required<LyxalOptional> = Object.freeze({
	...defaultIconDimensions,
	...defaultIconTransformations,
});

/** Default values for all properties used in ExtendedLyxalIcon */
export const defaultExtendedIconProps: Required<FullExtendedLyxalIcon> =
	Object.freeze({
		...defaultIconProps,
		body: '',
		hidden: false,
	});
