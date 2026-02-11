import type { LyxalIcon } from '@lyxal-icon/types';
import type { LyxalIconName } from '@lyxal-icon/utils/lib/icon/name';
import type { LyxalIconLoaderAbort } from '@lyxal-icon/core/lib/api/icons';

/**
 * Value for currently selected icon
 */
export interface CurrentIconData {
	// Value passed as parameter
	value: unknown;

	// Data, if available. Can be null if icon is missing in API
	data?: LyxalIcon | null;

	// Icon name as object, if `value` is a valid icon name
	name?: LyxalIconName | null;

	// Loader abort function, set if icon is being loaded. Used only when `name` is valid
	loading?: LyxalIconLoaderAbort;
}

/**
 * Same as above, used if icon is currenly being rendered
 */
export interface RenderedCurrentIconData extends CurrentIconData {
	// Icon data
	data: LyxalIcon;
}
