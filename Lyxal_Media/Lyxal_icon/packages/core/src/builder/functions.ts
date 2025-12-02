import type { LyxalIcon } from '@lyxal-icon/types';
import type { LyxalIconCustomisations } from '@lyxal-icon/utils/lib/customisations/defaults';
import type { LyxalIconBuildResult } from '@lyxal-icon/utils/lib/svg/build';

/**
 * Interface for exported builder functions
 */
export interface LyxalBuilderFunctions {
	replaceIDs?: (body: string) => string;
	clearIDCache?: () => void;
	calculateSize: (
		size: string | number,
		ratio: number,
		precision?: number
	) => string | number;
	buildIcon: (
		icon: LyxalIcon,
		customisations?: LyxalIconCustomisations
	) => LyxalIconBuildResult;
}
