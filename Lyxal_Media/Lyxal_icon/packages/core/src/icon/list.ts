import type { LyxalIconName } from '@lyxal-icon/utils/lib/icon/name';
import { stringToIcon } from '@lyxal-icon/utils/lib/icon/name';

/**
 * Convert icons list from string/icon mix to icons and validate them
 */
export function listToIcons(
	list: (string | LyxalIconName)[],
	validate = true,
	simpleNames = false
): LyxalIconName[] {
	const result: LyxalIconName[] = [];

	list.forEach((item) => {
		const icon =
			typeof item === 'string'
				? (stringToIcon(item, validate, simpleNames) as LyxalIconName)
				: item;
		if (icon) {
			result.push(icon);
		}
	});

	return result;
}

/**
 * Get all providers
 */
export function getProviders(list: LyxalIconName[]): string[] {
	const providers = Object.create(null) as Record<string, boolean>;
	list.forEach((icon) => {
		providers[icon.provider] = true;
	});
	return Object.keys(providers);
}
