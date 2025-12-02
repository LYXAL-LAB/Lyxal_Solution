import React from 'react';
import 'Lyxal-icon';

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
 * Properties for React component
 */
export interface LyxalIconProps
	extends React.HTMLProps<HTMLElement>,
		LyxalIconProperties {
	// Rotation can be string or number
	rotate?: string | number;
}

/**
 * React component
 */
export const Icon = React.forwardRef(
	(
		props: LyxalIconProps,
		ref: React.ForwardedRef<LyxalIconHTMLElement>
	) => {
		const newProps: Record<string, unknown> = {
			...props,
			ref,
		};

		// Stringify icon
		if (typeof props.icon === 'object') {
			newProps.icon = JSON.stringify(props.icon);
		}

		// Boolean
		if (!props.inline) {
			delete newProps.inline;
		}

		// React cannot handle className for web components
		if (props.className) {
			newProps['class'] = props.className;
		}

		return React.createElement('Lyxal-icon', newProps);
	}
);
