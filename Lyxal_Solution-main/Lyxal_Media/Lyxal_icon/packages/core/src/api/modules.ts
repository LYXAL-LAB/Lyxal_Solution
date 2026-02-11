import type { QueryModuleResponse } from '@Lyxal/api-redundancy';

/**
 * Params for sendQuery()
 */
export interface LyxalAPIIconsQueryParams {
	type: 'icons';
	provider: string;
	prefix: string;
	icons: string[];
}
export interface LyxalAPICustomQueryParams {
	type: 'custom';
	provider?: string; // Provider is optional. If missing, temporary config is created based on host
	uri: string;
}

export type LyxalAPIQueryParams =
	| LyxalAPIIconsQueryParams
	| LyxalAPICustomQueryParams;

/**
 * Functions to implement in module
 */
export type LyxalAPIPrepareIconsQuery = (
	provider: string,
	prefix: string,
	icons: string[]
) => LyxalAPIIconsQueryParams[];

export type LyxalAPISendQuery = (
	host: string,
	params: LyxalAPIQueryParams,
	callback: QueryModuleResponse
) => void;

/**
 * API modules
 */
export interface LyxalAPIModule {
	prepare: LyxalAPIPrepareIconsQuery;
	send: LyxalAPISendQuery;
}

/**
 * Local storate types and entries
 */
const storage = Object.create(null) as Record<string, LyxalAPIModule>;

/**
 * Set API module
 */
export function setAPIModule(provider: string, item: LyxalAPIModule): void {
	storage[provider] = item;
}

/**
 * Get API module
 */
export function getAPIModule(provider: string): LyxalAPIModule | undefined {
	return storage[provider] || storage[''];
}
