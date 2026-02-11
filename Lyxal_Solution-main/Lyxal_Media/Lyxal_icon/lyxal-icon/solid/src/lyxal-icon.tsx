import type { JSX } from 'solid-js';

import type {
	LyxalIcon,
	LyxalIconProperties,
	LyxalIconAttributes,
	LyxalIconHTMLElement,
} from 'Lyxal-icon';

/**
 * Export types
 */
export type {
	LyxalStorageFunctions,
	LyxalBuilderFunctions,
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
} from 'Lyxal-icon';

// JSON stuff
export type { LyxalIcon, LyxalJSON, LyxalIconName } from 'Lyxal-icon';

// Customisations
export type { LyxalIconCustomisations, LyxalIconSize } from 'Lyxal-icon';

// API
export type {
	LyxalAPIConfig,
	LyxalIconLoaderCallback,
	LyxalIconLoaderAbort,
	LyxalAPIModule,
	GetAPIConfig,
	LyxalAPIPrepareIconsQuery,
	LyxalAPISendQuery,
	PartialLyxalAPIConfig,
	LyxalAPIQueryParams,
	LyxalAPICustomQueryParams,
	LyxalCustomIconLoader,
	LyxalCustomIconsLoader,
} from 'Lyxal-icon';

// Builder functions
export type { LyxalIconBuildResult } from 'Lyxal-icon';

// Component types
export type {
	LyxalIconAttributes,
	LyxalIconProperties,
	LyxalRenderMode,
	LyxalIconHTMLElement,
} from 'Lyxal-icon';

/**
 * Export functions
 */
export {
	iconLoaded,
	getIcon,
	listIcons,
	addIcon,
	addCollection,
	calculateSize,
	buildIcon,
	loadIcons,
	loadIcon,
	addAPIProvider,
	setCustomIconLoader,
	setCustomIconsLoader,
	appendCustomStyle,
	_api,
} from 'Lyxal-icon';

/**
 * Properties for Solid component
 */
type BaseElementProps = JSX.IntrinsicElements['span'];
export interface LyxalIconProps
	extends BaseElementProps,
		LyxalIconProperties {
	// Rotation can be string or number
	rotate?: string | number;
}

/**
 * Solid component
 */
export function Icon(props: LyxalIconProps): JSX.Element {
	let {
		icon,
		mode,
		inline,
		rotate,
		flip,
		width,
		height,
		preserveAspectRatio,
		noobserver,
	} = props;

	// Convert icon to string
	if (typeof icon === 'object') {
		icon = JSON.stringify(icon);
	}

	return (
		// @ts-ignore
		<Lyxal-icon
			attr:icon={icon}
			attr:mode={mode}
			attr:inline={inline}
			attr:rotate={rotate}
			attr:flip={flip}
			attr:width={width}
			attr:height={height}
			attr:preserveAspectRatio={preserveAspectRatio}
			attr:noobserver={noobserver}
			{...props}
		/>
	);
}
