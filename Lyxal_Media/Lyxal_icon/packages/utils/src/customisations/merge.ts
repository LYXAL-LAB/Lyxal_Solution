import {
	defaultIconSizeCustomisations,
	FullIconCustomisations,
	LyxalIconCustomisations,
	LyxalIconSizeCustomisations,
} from './defaults';

/**
 * Convert LyxalIconCustomisations to FullIconCustomisations, checking value types
 */
export function mergeCustomisations<T extends FullIconCustomisations>(
	defaults: T,
	item: LyxalIconCustomisations
): T {
	// Copy default values
	const result = {
		...defaults,
	};

	// Merge all properties
	for (const key in item) {
		const value = item[key as keyof LyxalIconCustomisations];
		const valueType = typeof value;

		if (key in defaultIconSizeCustomisations) {
			// Dimension
			if (
				value === null ||
				(value && (valueType === 'string' || valueType === 'number'))
			) {
				result[key as keyof LyxalIconSizeCustomisations] =
					value as string;
			}
		} else if (valueType === typeof result[key as keyof T]) {
			// Normalise rotation, copy everything else as is
			(result as Record<string, unknown>)[key] =
				key === 'rotate' ? (value as number) % 4 : value;
		}
	}

	return result;
}
