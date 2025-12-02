import type {
	ExtendedLyxalIcon,
	LyxalAliases,
	LyxalJSON,
} from '@lyxal-icon/types';
import { mergeIconData } from '../icon/merge';
import { getIconsTree } from './tree';

/**
 * Get icon data, using prepared aliases tree
 */
export function internalGetIconData(
	data: LyxalJSON,
	name: string,
	tree: string[]
): ExtendedLyxalIcon {
	const icons = data.icons;
	const aliases = data.aliases || (Object.create(null) as LyxalAliases);

	let currentProps = {} as ExtendedLyxalIcon;

	// Parse parent item
	function parse(name: string) {
		currentProps = mergeIconData(
			icons[name] || aliases[name],
			currentProps
		);
	}

	parse(name);
	tree.forEach(parse);

	// Add default values
	return mergeIconData(data, currentProps) as unknown as ExtendedLyxalIcon;
}

/**
 * Get data for icon
 */
export function getIconData(
	data: LyxalJSON,
	name: string
): ExtendedLyxalIcon | null {
	if (data.icons[name]) {
		// Parse only icon
		return internalGetIconData(data, name, []);
	}

	// Resolve tree
	const tree = getIconsTree(data, [name])[name];
	return tree ? internalGetIconData(data, name, tree) : null;
}
