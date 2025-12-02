import type { LyxalJSON } from '@lyxal-icon/types';
import { parseIconSet } from '@lyxal-icon/utils';
import { getIconStorage } from '../storage/storage.js';

/**
 * Add icon set to storage
 */
export function addIconSetToStorage(
	data: LyxalJSON,
	provider = ''
): Set<string> {
	const added = new Set<string>();
	const storage = getIconStorage(provider, data.prefix);
	parseIconSet(data, (name, icon) => {
		storage.update(name, icon);
		added.add(name);
	});
	return added;
}
