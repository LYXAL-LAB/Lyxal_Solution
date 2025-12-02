import type {
	QueryAbortCallback,
	QueryDoneCallback,
} from '@Lyxal/api-redundancy';
import type { LyxalIconName } from '@Lyxal/utils/lib/icon/name';
import type {
	LyxalIconLoaderAbort,
	LyxalIconLoaderCallback,
} from './icons';
import type { GetAPIConfig, PartialLyxalAPIConfig } from './config';
import type {
	LyxalAPIModule,
	LyxalAPIQueryParams,
	LyxalAPICustomQueryParams,
} from './modules';
import type { LyxalIcon } from '@Lyxal/types';
import type {
	LyxalCustomIconLoader,
	LyxalCustomIconsLoader,
} from './types';

/**
 * Lyxal API functions
 */
export interface LyxalAPIFunctions {
	/**
	 * Load icons
	 */
	loadIcons: (
		icons: (LyxalIconName | string)[],
		callback?: LyxalIconLoaderCallback
	) => LyxalIconLoaderAbort;

	/**
	 * Load one icon, using Promise syntax
	 */
	loadIcon: (
		icon: LyxalIconName | string
	) => Promise<Required<LyxalIcon>>;

	/**
	 * Add API provider
	 */
	addAPIProvider: (
		provider: string,
		customConfig: PartialLyxalAPIConfig
	) => boolean;

	/**
	 * Set custom loader for multple icons
	 */
	setCustomIconsLoader: (
		callback: LyxalCustomIconsLoader,
		prefix: string,
		provider?: string
	) => void;

	/**
	 * Set custom loader for one icon
	 */
	setCustomIconLoader: (
		callback: LyxalCustomIconLoader,
		prefix: string,
		provider?: string
	) => void;
}

/**
 * Exposed internal functions
 *
 * Used by plug-ins, such as Icon Finder
 *
 * Important: any changes published in a release must be backwards compatible.
 */
export interface LyxalAPIInternalFunctions {
	/**
	 * Get API config, used by custom modules
	 */
	getAPIConfig: GetAPIConfig;

	/**
	 * Set custom API module
	 */
	setAPIModule: (provider: string, item: LyxalAPIModule) => void;

	/**
	 * Send API query
	 */
	sendAPIQuery: (
		target: string | PartialLyxalAPIConfig,
		query: LyxalAPIQueryParams,
		callback: QueryDoneCallback
	) => QueryAbortCallback;

	/**
	 * Set and get fetch()
	 */
	setFetch: (item: typeof fetch) => void;
	getFetch: () => typeof fetch | undefined;

	/**
	 * List all API providers (from config)
	 */
	listAPIProviders: () => string[];
}

/**
 * Types needed for internal functions
 */
export type { LyxalAPIQueryParams, LyxalAPICustomQueryParams };
