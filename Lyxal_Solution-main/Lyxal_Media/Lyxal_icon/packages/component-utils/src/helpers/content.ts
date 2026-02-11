import type { LyxalIcon } from '@lyxal-icon/types';
import { replaceIDs } from '@lyxal-icon/utils/lib/svg/id';
import { iconToSVG } from '@lyxal-icon/utils/lib/svg/build';

/**
 * Convert content to string, replacing IDs to make them unique
 */
export function renderContent(content: string | LyxalIcon): string {
	return replaceIDs(
		typeof content === 'string' ? content : iconToSVG(content).body
	);
}
