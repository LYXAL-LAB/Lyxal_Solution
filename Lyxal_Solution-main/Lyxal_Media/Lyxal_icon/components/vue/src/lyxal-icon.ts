import {
	defineComponent,
	onMounted,
	onUnmounted,
	ref,
	shallowRef,
	nextTick,
	watch,
} from 'vue';
import type { LyxalJSON, LyxalIcon } from '@Lyxal/types';

// Core
import type { LyxalIconName } from '@Lyxal/utils/lib/icon/name';
import { stringToIcon } from '@Lyxal/utils/lib/icon/name';
import type { LyxalIconSize } from '@Lyxal/utils/lib/customisations/defaults';
import type { LyxalStorageFunctions } from '@Lyxal/core/lib/storage/functions';
import {
	iconLoaded,
	getIcon,
	addIcon,
	addCollection,
	getIconData,
	allowSimpleNames,
} from '@Lyxal/core/lib/storage/functions';
import { listIcons } from '@Lyxal/core/lib/storage/storage';
import type { LyxalBuilderFunctions } from '@Lyxal/core/lib/builder/functions';
import { iconToSVG as buildIcon } from '@Lyxal/utils/lib/svg/build';
import { replaceIDs, clearIDCache } from '@Lyxal/utils/lib/svg/id';
import { calculateSize } from '@Lyxal/utils/lib/svg/size';
import type { LyxalIconBuildResult } from '@Lyxal/utils/lib/svg/build';
import { defaultIconProps } from '@Lyxal/utils/lib/icon/defaults';

// API
import type {
	LyxalCustomIconLoader,
	LyxalCustomIconsLoader,
} from '@Lyxal/core/lib/api/types';
import type {
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
	LyxalAPIQueryParams,
	LyxalAPICustomQueryParams,
} from '@Lyxal/core/lib/api/functions';
import type {
	LyxalAPIModule,
	LyxalAPISendQuery,
	LyxalAPIPrepareIconsQuery,
} from '@Lyxal/core/lib/api/modules';
import { setAPIModule } from '@Lyxal/core/lib/api/modules';
import type {
	PartialLyxalAPIConfig,
	LyxalAPIConfig,
	GetAPIConfig,
} from '@Lyxal/core/lib/api/config';
import {
	addAPIProvider,
	getAPIConfig,
	listAPIProviders,
} from '@Lyxal/core/lib/api/config';
import {
	fetchAPIModule,
	setFetch,
	getFetch,
} from '@Lyxal/core/lib/api/modules/fetch';
import type {
	LyxalIconLoaderCallback,
	LyxalIconLoaderAbort,
} from '@Lyxal/core/lib/api/icons';
import { loadIcons, loadIcon } from '@Lyxal/core/lib/api/icons';
import {
	setCustomIconLoader,
	setCustomIconsLoader,
} from '@Lyxal/core/lib/api/loaders';
import { sendAPIQuery } from '@Lyxal/core/lib/api/query';

// Properties
import type {
	IconProps,
	LyxalIconCustomisations,
	LyxalIconProps,
	LyxalRenderMode,
	LyxalIconCustomiseCallback,
} from './props';

// Render SVG
import { render } from './render';

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
	LyxalIconCustomiseCallback,
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
 * Empty icon data, rendered when icon is not available
 */
const emptyIcon = {
	...defaultIconProps,
	body: '',
};

/**
 * Component
 */
export const Icon = defineComponent<IconProps>(
	(props: IconProps, { emit }) => {
		// Loader
		interface LoaderState {
			name: string;
			abort?: () => void;
		}
		const loader = ref<LoaderState | null>(null);

		function abortLoading() {
			if (loader.value) {
				loader.value.abort?.();
				loader.value = null;
			}
		}

		// Render state
		const rendering = ref(!!props.ssr);
		const lastRenderedIconName = ref('');

		// Icon data
		interface IconComponentData {
			data: LyxalIcon;
			classes?: string[];
		}
		const iconData = shallowRef<IconComponentData | null>(null);

		// Update icon data
		function getIcon(): IconComponentData | null {
			const icon = props.icon;

			// Icon is an object
			if (
				typeof icon === 'object' &&
				icon !== null &&
				typeof icon.body === 'string'
			) {
				lastRenderedIconName.value = '';
				return {
					data: icon,
				};
			}

			// Check for valid icon name
			let iconName: LyxalIconName | null;
			if (
				typeof icon !== 'string' ||
				(iconName = stringToIcon(icon, false, true)) === null
			) {
				return null;
			}

			// Load icon
			let data = getIconData(iconName);
			if (!data) {
				// Icon data is not available
				const oldState = loader.value;
				if (!oldState || oldState.name !== icon) {
					// Icon name does not match old loader state
					if (data === null) {
						// Failed to load
						loader.value = {
							name: icon,
						};
					} else {
						loader.value = {
							name: icon,
							abort: loadIcons([iconName], updateIconData),
						};
					}
				}
				return null;
			}

			// Icon data is available
			abortLoading();
			if (lastRenderedIconName.value !== icon) {
				lastRenderedIconName.value = icon;
				// Emit on next tick because render will be called on next tick
				nextTick(() => {
					emit('load', icon);
				});
			}

			// Customise icon
			const customise = props.customise;
			if (customise) {
				// Clone data and customise it
				data = Object.assign({}, data);
				const customised = customise(
					data.body,
					iconName.name,
					iconName.prefix,
					iconName.provider
				);
				if (typeof customised === 'string') {
					data.body = customised;
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

		function updateIconData() {
			const icon = getIcon();
			if (!icon) {
				iconData.value = null;
			} else if (icon.data !== iconData.value?.data) {
				iconData.value = icon;
			}
		}

		// Set icon data
		if (rendering.value) {
			updateIconData();
		} else {
			onMounted(() => {
				rendering.value = true;
				updateIconData();
			});
		}
		watch(() => props.icon, updateIconData);

		// Abort loading on unmount
		onUnmounted(abortLoading);

		// Render function
		return () => {
			// Get icon data
			const icon = iconData.value;

			if (!icon) {
				// Icon is not available
				return render(emptyIcon, props);
			}

			// Add classes
			let newProps = props as LyxalIconProps & { class?: string };
			if (icon.classes) {
				newProps = {
					...props,
					class: icon.classes.join(' '),
				};
			}

			// Render icon
			return render(
				{
					...defaultIconProps,
					...icon.data,
				},
				newProps
			);
		};
	},
	{
		props: [
			// Icon and render mode
			'icon',
			'mode',
			'ssr',
			// Layout and style
			'width',
			'height',
			'style',
			'color',
			'inline',
			// Transformations
			'rotate',
			'hFlip',
			'horizontalFlip',
			'vFlip',
			'verticalFlip',
			'flip',
			// Misc
			'id',
			'ariaHidden',
			'customise',
			'title',
		],
		emits: ['load'],
	}
);

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
