import { getStorage } from '../storage/storage';
import type {
	LyxalCustomIconLoader,
	LyxalCustomIconsLoader,
	IconStorageWithAPI,
} from './types';

// Custom loaders
// You can set only one of these loaders, whichever is more suitable for your use case.

/**
 * Set custom loader for multiple icons
 */
export function setCustomIconsLoader(
	loader: LyxalCustomIconsLoader,
	prefix: string,
	provider?: string
): void {
	// Assign loader directly to storage
	(getStorage(provider || '', prefix) as IconStorageWithAPI).loadIcons =
		loader;
}

/**
 * Set custom loader for one icon
 */
export function setCustomIconLoader(
	loader: LyxalCustomIconLoader,
	prefix: string,
	provider?: string
): void {
	// Assign loader directly to storage
	(getStorage(provider || '', prefix) as IconStorageWithAPI).loadIcon =
		loader;
}
