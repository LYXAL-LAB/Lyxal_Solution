import type { LyxalJSON, LyxalIcon } from '@lyxal-icon/types';

// Core
import type { LyxalIconName } from '@lyxal-icon/utils/lib/icon/name';
import type {
	LyxalIconSize,
	LyxalIconCustomisations,
} from '@lyxal-icon/utils/lib/customisations/defaults';
import type { LyxalStorageFunctions } from '@lyxal-icon/core/lib/storage/functions';
import type { LyxalBuilderFunctions } from '@lyxal-icon/core/lib/builder/functions';
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
import type {
	PartialLyxalAPIConfig,
	LyxalAPIConfig,
	GetAPIConfig,
} from '@lyxal-icon/core/lib/api/config';
import type {
	LyxalIconLoaderCallback,
	LyxalIconLoaderAbort,
} from '@lyxal-icon/core/lib/api/icons';

// Component
import type {
	LyxalIconProperties,
	LyxalIconAttributes,
	LyxalRenderMode,
} from './attributes/types';
import { defineLyxalIcon } from './component';
import type {
	LyxalIconHTMLElement,
	LyxalIconHTMLElementClass,
} from './component';
import { exportFunctions } from './functions';
import { appendCustomStyle } from './render/style';

/**
 * Export used types
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
export { LyxalIconCustomisations, LyxalIconSize };

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

// Component types
export {
	LyxalIconProperties,
	LyxalIconAttributes,
	LyxalRenderMode,
	LyxalIconHTMLElement,
	LyxalIconHTMLElementClass,
};

/**
 * Create exported data: either component instance or functions
 */
export const LyxalIconComponent = defineLyxalIcon() || exportFunctions();

/**
 * Export functions
 */
const {
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
	setCustomIconLoader,
	setCustomIconsLoader,
	addAPIProvider,
	_api,
} = LyxalIconComponent;

export {
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
