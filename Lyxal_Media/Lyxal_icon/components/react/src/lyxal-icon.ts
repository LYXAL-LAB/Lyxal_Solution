import { useEffect, useState, forwardRef, createElement } from 'react';
import type { Ref, JSX } from 'react';
import type { LyxalJSON, LyxalIcon } from '@lyxal-icon/types';

// Core
import type { LyxalIconName } from '@lyxal-icon/utils/lib/icon/name';
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
	LyxalIconOnLoad,
	LyxalIconCustomisations,
	LyxalIconProps,
	LyxalRenderMode,
	IconProps,
	IconElement,
} from './props';

// Render SVG
import { render } from './render';
import { defaultIconProps } from '@lyxal-icon/utils/lib/icon/defaults';

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

// Customisations and icon props
export {
	LyxalIconCustomisations,
	LyxalIconSize,
	LyxalRenderMode,
	LyxalIconProps,
	IconProps,
	LyxalIconOnLoad,
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
 * Component
 */
interface InternalIconProps extends IconProps {
	_ref?: Ref<IconElement> | null;
}

function IconComponent(props: InternalIconProps): JSX.Element {
	interface AbortState {
		callback?: LyxalIconLoaderAbort;
	}
	interface State {
		// Currently rendered icon
		name: string;

		// Icon data, null if missing
		data?: LyxalIcon | null;
	}

	const [mounted, setMounted] = useState(!!props.ssr);
	const [abort, setAbort] = useState<AbortState>({});

	// Get initial state
	function getInitialState(mounted: boolean): State {
		if (mounted) {
			const name = props.icon;
			if (typeof name === 'object') {
				// Icon as object
				return {
					name: '',
					data: name,
				};
			}

			const data = getIconData(name);
			if (data) {
				return {
					name,
					data,
				};
			}
		}
		return {
			name: '',
		};
	}
	const [state, setState] = useState<State>(getInitialState(!!props.ssr));

	// Cancel loading
	function cleanup() {
		const callback = abort.callback;
		if (callback) {
			callback();
			setAbort({});
		}
	}

	// Change state if it is different
	function changeState(newState: State): boolean | undefined {
		if (JSON.stringify(state) !== JSON.stringify(newState)) {
			cleanup();
			setState(newState);
			return true;
		}
	}

	// Update state
	function updateState() {
		const name = props.icon;
		if (typeof name === 'object') {
			// Icon as object
			changeState({
				name: '',
				data: name,
			});
			return;
		}

		// New icon or got icon data
		const data = getIconData(name);
		if (
			changeState({
				name,
				data,
			})
		) {
			if (data === undefined) {
				// Load icon, update state when done
				const callback = loadIcons([name], updateState);
				setAbort({
					callback,
				});
			} else if (data) {
				// Icon data is available: trigger onLoad callback if present
				props.onLoad?.(name);
			}
		}
	}

	// Mounted state, cleanup for loader
	useEffect(() => {
		setMounted(true);
		return cleanup;
	}, []);

	// Icon changed or component mounted
	useEffect(() => {
		if (mounted) {
			updateState();
		}
	}, [props.icon, mounted]);

	// Render icon
	const { name, data } = state;
	if (!data) {
		return props.children
			? (props.children as JSX.Element)
			: props.fallback
				? (props.fallback as JSX.Element)
				: createElement('span', {});
	}

	return render(
		{
			...defaultIconProps,
			...data,
		},
		props,
		name
	);
}

// Component type
type IconComponentType = (props: IconProps) => JSX.Element;

/**
 * Block icon
 *
 * @param props - Component properties
 */
export const Icon = forwardRef<IconElement, IconProps>((props, ref) =>
	IconComponent({
		...props,
		_ref: ref,
	})
) as IconComponentType;

/**
 * Inline icon (has negative verticalAlign that makes it behave like icon font)
 *
 * @param props - Component properties
 */
export const InlineIcon = forwardRef<IconElement, IconProps>((props, ref) =>
	IconComponent({
		inline: true,
		...props,
		_ref: ref,
	})
) as IconComponentType;

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
