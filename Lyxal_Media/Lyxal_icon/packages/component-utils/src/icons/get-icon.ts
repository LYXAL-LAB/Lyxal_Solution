import type { LyxalIcon } from '@lyxal-icon/types';
import { stringToIcon, type LyxalIconName } from '@lyxal-icon/utils';
import { getIconStorage } from '../storage/storage.js';

/**
 * Get icon data
 *
 * Returns icon data if icon is loaded, null if icon is missing, undefined if icon is unknown
 */
export function getLoadedIcon(
	iconName: string | LyxalIconName
): LyxalIcon | null | undefined {
	const icon =
		typeof iconName === 'string' ? stringToIcon(iconName) : iconName;
	if (!icon) {
		return null;
	}

	const storage = getIconStorage(icon.provider, icon.prefix);

	return (
		storage.icons[icon.name] ??
		(storage.missing.has(icon.name) ? null : undefined)
	);
}
