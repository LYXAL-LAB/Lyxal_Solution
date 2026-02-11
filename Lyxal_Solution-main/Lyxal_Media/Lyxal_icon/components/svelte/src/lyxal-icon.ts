/**
 * Export required types
 */
// Function sets
export {
	LyxalStorageFunctions,
	LyxalBuilderFunctions,
	LyxalAPIFunctions,
	LyxalAPIInternalFunctions,
} from './functions';

// JSON stuff
export { LyxalIcon, LyxalJSON, LyxalIconName } from './functions';

// Customisations
export {
	LyxalIconCustomisations,
	LyxalIconSize,
	LyxalIconProps,
	IconProps,
	LyxalRenderMode,
} from './functions';

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
} from './functions';

// Builder functions
export { LyxalIconBuildResult } from './functions';

// Component params
export { LyxalIconOnLoad } from './functions';

// Functions
// Important: duplicate of global exports in Icon.svelte. When changing exports, they must be changed in both files.
export {
	iconLoaded,
	getIcon,
	listIcons,
	addIcon,
	addCollection,
} from './functions';

export {
	calculateSize,
	replaceIDs,
	clearIDCache,
	buildIcon,
} from './functions';

export {
	addAPIProvider,
	loadIcons,
	loadIcon,
	setCustomIconLoader,
	setCustomIconsLoader,
	_api,
} from './functions';
