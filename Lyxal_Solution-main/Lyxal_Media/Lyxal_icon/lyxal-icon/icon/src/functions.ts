import type { LyxalJSON } from '@lyxal-icon/types';

// Core
import {
	allowSimpleNames,
	LyxalStorageFunctions,
} from '@lyxal-icon/core/lib/storage/functions';
import {
	iconLoaded,
	getIcon,
	addIcon,
	addCollection,
} from '@lyxal-icon/core/lib/storage/functions';
import { listIcons } from '@lyxal-icon/core/lib/storage/storage';
import type { LyxalBuilderFunctions } from '@lyxal-icon/core/lib/builder/functions';
import { iconToSVG as buildIcon } from '@lyxal-icon/utils/lib/svg/build';
import { calculateSize } from '@lyxal-icon/utils/lib/svg/size';

// Custom additions used for building icons that are used by component
// Can be reused for building icons in SSR and assigning it as content of component
import { iconToHTML } from '@lyxal-icon/utils/lib/svg/html';
import { svgToURL } from '@lyxal-icon/utils/lib/svg/url';

// API
import type {
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
} from '@lyxal-icon/core/lib/api/functions';
import { setAPIModule } from '@lyxal-icon/core/lib/api/modules';
import type { PartialLyxalAPIConfig } from '@lyxal-icon/core/lib/api/config';
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
import { loadIcons, loadIcon } from '@lyxal-icon/core/lib/api/icons';
import { sendAPIQuery } from '@lyxal-icon/core/lib/api/query';
import {
	setCustomIconLoader,
	setCustomIconsLoader,
} from '@lyxal-icon/core/lib/api/loaders';

// Misc
import { appendCustomStyle } from './render/style';

/**
 * Interface for exported functions
 */
export interface LyxalExportedFunctions
	extends LyxalStorageFunctions,
	LyxalBuilderFunctions,
	LyxalAPIFunctions {
	// API internal functions
	_api: LyxalAPIInternalFunctions;

	// Append custom style to all components
	appendCustomStyle: (value: string) => void;

	// Render HTML
	iconToHTML: (body: string, attributes: Record<string, string>) => string;
	svgToURL: (svg: string) => string;
}

/**
 * Get functions and initialise stuff
 */
export function exportFunctions(): LyxalExportedFunctions {
	/**
	 * Initialise stuff
	 */
	// Set API module
	setAPIModule('', fetchAPIModule);

	// Allow simple icon names
	allowSimpleNames(true);

	/**
	 * Browser stuff
	 */
	interface WindowWithLyxalStuff {
		LyxalPreload?: LyxalJSON[] | LyxalJSON;
		LyxalProviders?: Record<string, PartialLyxalAPIConfig>;
	}
	let _window: WindowWithLyxalStuff;
	try {
		_window = window as WindowWithLyxalStuff;
		// eslint-disable-next-line @typescript-eslint/no-unused-vars
	} catch (err) {
		//
	}
	if (_window) {
		// Load icons from global "LyxalPreload"
		if (_window.LyxalPreload !== void 0) {
			const preload = _window.LyxalPreload;
			const err = 'Invalid LyxalPreload syntax.';
			if (typeof preload === 'object' && preload !== null) {
				(preload instanceof Array ? preload : [preload]).forEach(
					(item) => {
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
							// eslint-disable-next-line @typescript-eslint/no-unused-vars
						} catch (e) {
							console.error(err);
						}
					}
				);
			}
		}

		// Set API from global "LyxalProviders"
		if (_window.LyxalProviders !== void 0) {
			const providers = _window.LyxalProviders;
			if (typeof providers === 'object' && providers !== null) {
				for (const key in providers) {
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
						// eslint-disable-next-line @typescript-eslint/no-unused-vars
					} catch (e) {
						console.error(err);
					}
				}
			}
		}
	}

	const _api: LyxalAPIInternalFunctions = {
		getAPIConfig,
		setAPIModule,
		sendAPIQuery,
		setFetch,
		getFetch,
		listAPIProviders,
	};

	return {
		iconLoaded,
		getIcon,
		listIcons,
		addIcon,
		addCollection,
		calculateSize,
		buildIcon,
		iconToHTML,
		svgToURL,
		loadIcons,
		loadIcon,
		addAPIProvider,
		setCustomIconLoader,
		setCustomIconsLoader,
		appendCustomStyle,
		_api,
	};
}
