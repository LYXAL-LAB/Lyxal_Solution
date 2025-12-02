// Types
export type { LyxalJSON, LyxalIcon } from '@lyxal-icon/types';
export type { LyxalIconSize } from '@lyxal-icon/utils/lib/customisations/defaults';

// Types from props.ts
export type {
	LyxalIconCustomisations,
	IconProps,
	LyxalRenderMode,
} from './props';

// Functions
// Important: duplicate of global exports in OfflineIcon.svelte. When changing exports, they must be changed in both files.
export { addIcon, addCollection } from './offline-functions';
