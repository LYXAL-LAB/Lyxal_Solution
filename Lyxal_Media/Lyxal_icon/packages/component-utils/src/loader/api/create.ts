import { matchIconName } from '@lyxal-icon/utils';
import { fetchJSON } from '@lyxal-icon/fetch';
import type { LoaderConfig } from '../types.js';
import type { LyxalJSON } from '@lyxal-icon/types';

/**
 * Create loader for Lyxal API
 */
export function createLyxalAPILoader(
	host: string | string[],
	init?: RequestInit,
	checkSSR = true
): LoaderConfig {
	const hosts = Array.isArray(host) ? host : [host];

	// Check for SSR environment: do not send API requests in SSR
	const isSSR = checkSSR
		? typeof window === 'undefined' || !window.document
		: checkSSR;

	return {
		maxCount: 32,
		maxLength: 480,
		validateNames: true,
		hosts,
		loadIcons: async (names: string[], prefix: string) => {
			if (isSSR || !matchIconName.test(prefix)) {
				// Invalid prefix or SSR environment
				return {
					prefix,
					icons: Object.create(null),
					not_found: names,
				};
			}

			// Get URL for API request
			const url = `/${prefix}.json?icons=${names.join(',')}`;

			// Fetch data
			return await fetchJSON<LyxalJSON>(hosts, url, init);
		},
	};
}
