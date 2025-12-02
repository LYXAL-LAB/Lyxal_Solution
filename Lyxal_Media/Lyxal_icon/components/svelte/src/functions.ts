import type { LyxalJSON, LyxalIcon } from '@lyxal-icon/types';

// Core
import type { LyxalIconName } from '@lyxal-icon/utils/lib/icon/name';
import { stringToIcon } from '@lyxal-icon/utils/lib/icon/name';
import type { LyxalIconSize } from '@lyxal-icon/utils/lib/customisations/defaults';
import type { LyxalStorageFunctions } from '@lyxal-icon/core/lib/storage/functions';
import {
	iconLoaded,
	getIcon,
	addIcon,
	addCollection,
	getIconData,
	allowSimpleNames,
} from '@lyxal-icon/core/lib/storage/functions';
import { listIcons } from '@lyxal-icon/core/lib/storage/storage';
import type { LyxalBuilderFunctions } from '@lyxal-icon/core/lib/builder/functions';
import { iconToSVG as buildIcon } from '@lyxal-icon/utils/lib/svg/build';
import { replaceIDs, clearIDCache } from '@lyxal-icon/utils/lib/svg/id';
import { calculateSize } from '@lyxal-icon/utils/lib/svg/size';
import type { LyxalIconBuildResult } from '@lyxal-icon/utils/lib/svg/build';
import { defaultIconProps } from '@lyxal-icon/utils/lib/icon/defaults';

// API
import type {
	LyxalCustomIconLoader,
	LyxalCustomIconsLoader,
} from '@lyxal-icon/core/lib/api/types';
import type {
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
	LyxalAPIQueryParams,
	LyxalAPICustomQueryParams,
} from '@lyxal-icon/core/lib/api/functions';
import type {
	LyxalAPIModule,
	LyxalAPISendQuery,
	LyxalAPIPrepareIconsQuery,
} from '@lyxal-icon/core/lib/api/modules';
import { setAPIModule } from '@lyxal-icon/core/lib/api/modules';
import type {
	PartialLyxalAPIConfig,
	LyxalAPIConfig,
	GetAPIConfig,
} from '@lyxal-icon/core/lib/api/config';
import {
	addAPIProvider,
	getAPIConfig,
	listAPIProviders,
} from '@lyxal-icon/core/lib/api/config';
import {
	fetchAPIModule,
	setFetch,
	getFetch,
} from '@lyxal-icon/core/lib/api/modules/fetch';
import type {
	LyxalIconLoaderCallback,
	LyxalIconLoaderAbort,
} from '@lyxal-icon/core/lib/api/icons';
import { loadIcons, loadIcon } from '@lyxal-icon/core/lib/api/icons';
import {
	setCustomIconLoader,
	setCustomIconsLoader,
} from '@lyxal-icon/core/lib/api/loaders';
import { sendAPIQuery } from '@lyxal-icon/core/lib/api/query';

// Properties
import type {
	IconProps,
	LyxalIconCustomisations,
	LyxalIconProps,
	LyxalRenderMode,
} from './props';

// Render SVG
import { render } from './render';
import type { RenderResult } from './render';

/**
 * Export required types
 */
// Function sets
export {
	LyxalStorageFunctions,
	LyxalBuilderFunctions,
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
};

// JSON stuff
export { LyxalIcon, LyxalJSON, LyxalIconName };

// Customisations
export {
	LyxalIconCustomisations,
	LyxalIconSize,
	LyxalRenderMode,
	LyxalIconProps,
	IconProps,
};

// API
export {
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
};

// Builder functions
export { LyxalIconBuildResult };

/**
 * Initialise stuff
 */
// Enable short names
allowSimpleNames(true);

// Set API module
setAPIModule('', fetchAPIModule);

/**
 * Browser stuff
 */
if (typeof document !== 'undefined' && typeof window !== 'undefined') {
	interface WindowWithLyxalStuff {
		LyxalPreload?: LyxalJSON[] | LyxalJSON;
		LyxalProviders?: Record<string, PartialLyxalAPIConfig>;
	}
	const _window = window as WindowWithLyxalStuff;

	// Load icons from global "LyxalPreload"
	if (_window.LyxalPreload !== void 0) {
		const preload = _window.LyxalPreload;
		const err = 'Invalid LyxalPreload syntax.';
		if (typeof preload === 'object' && preload !== null) {
			(preload instanceof Array ? preload : [preload]).forEach((item) => {
				try {
					if (
						// Check if item is an object and not null/array
						typeof item !== 'object' ||
						item === null ||
						item instanceof Array ||
						// Check for 'icons' and 'prefix'
						typeof item.icons !== 'object' ||
						typeof item.prefix !== 'string' ||
						// Add icon set
						!addCollection(item)
					) {
						console.error(err);
					}
				} catch (e) {
					console.error(err);
				}
			});
		}
	}

	// Set API from global "LyxalProviders"
	if (_window.LyxalProviders !== void 0) {
		const providers = _window.LyxalProviders;
		if (typeof providers === 'object' && providers !== null) {
			for (let key in providers) {
				const err = 'LyxalProviders[' + key + '] is invalid.';
				try {
					const value = providers[key];
					if (
						typeof value !== 'object' ||
						!value ||
						value.resources === void 0
					) {
						continue;
					}
					if (!addAPIProvider(key, value)) {
						console.error(err);
					}
				} catch (e) {
					console.error(err);
				}
			}
		}
	}
}

/**
 * Function to get icon status
 */
interface IconLoadingState {
	name: string;
	abort: LyxalIconLoaderAbort;
}

type IconComponentData = LyxalIcon | null;

interface IconState {
	// Last icon name
	name: string;

	// Loading status
	loading: IconLoadingState | null;

	// True when component has been destroyed
	destroyed: boolean;
}

type IconStateCallback = () => void;

/**
 * Callback for when icon has been loaded (only triggered for icons loaded from API)
 */
export type LyxalIconOnLoad = (name: string) => void;

/**
 * checkIconState result
 */
export interface CheckIconStateResult {
	data: IconComponentData;
	classes?: string[];
}

/**
 * Check for SSR
 */
function isSSR() {
	try {
		return typeof window !== 'object';
	} catch (err) {
		return true;
	}
}

/**
 * Check if component needs to be updated
 */
export function checkIconState(
	icon: string | LyxalIcon,
	state: IconState,
	callback: IconStateCallback,
	onload?: LyxalIconOnLoad
): CheckIconStateResult | null {
	// Abort loading icon
	function abortLoading() {
		if (state.loading) {
			state.loading.abort();
			state.loading = null;
		}
	}

	// Icon is an object
	if (
		typeof icon === 'object' &&
		icon !== null &&
		typeof icon.body === 'string'
	) {
		// Stop loading
		state.name = '';
		abortLoading();
		return { data: { ...defaultIconProps, ...icon } };
	}

	// Invalid icon?
	let iconName: LyxalIconName | null;
	if (
		typeof icon !== 'string' ||
		(iconName = stringToIcon(icon, false, true)) === null
	) {
		abortLoading();
		return null;
	}

	// Load icon
	const data = getIconData(iconName);
	if (!data) {
		// Icon data is not available: load if not loading already
		if (!isSSR() && (!state.loading || state.loading.name !== icon)) {
			// New icon to load
			abortLoading();
			state.name = '';
			state.loading = {
				name: icon,
				abort: loadIcons([iconName], callback),
			};
		}
		return null;
	}

	// Icon data is available
	abortLoading();
	if (state.name !== icon) {
		state.name = icon;
		if (onload && !state.destroyed) {
			setTimeout(() => {
				onload(icon);
			});
		}
	}

	// Add classes
	const classes: string[] = ['Lyxal'];
	if (iconName.prefix !== '') {
		classes.push('Lyxal--' + iconName.prefix);
	}
	if (iconName.provider !== '') {
		classes.push('Lyxal--' + iconName.provider);
	}

	return { data, classes };
}

/**
 * Generate icon
 */
export function generateIcon(
	icon: IconComponentData,
	props: IconProps
): RenderResult | null {
	return icon
		? render(
			{
				...defaultIconProps,
				...icon,
			},
			props
		)
		: null;
}

/**
 * Internal API
 */
const _api: LyxalAPIInternalFunctions = {
	getAPIConfig,
	setAPIModule,
	sendAPIQuery,
	setFetch,
	getFetch,
	listAPIProviders,
};

/**
 * Export functions
 */
// LyxalAPIInternalFunctions
export { _api };

// LyxalAPIFunctions
export {
	addAPIProvider,
	loadIcons,
	loadIcon,
	setCustomIconLoader,
	setCustomIconsLoader,
};

// LyxalStorageFunctions
export { iconLoaded, getIcon, listIcons, addIcon, addCollection };

// LyxalBuilderFunctions
export { replaceIDs, clearIDCache, calculateSize, buildIcon };
