import { defineComponent, renderSlot } from 'vue';
import type { LyxalIcon, LyxalJSON } from '@Lyxal/types';
import type { LyxalIconSize } from '@Lyxal/utils/lib/customisations/defaults';
import { defaultIconProps } from '@Lyxal/utils/lib/icon/defaults';
import { parseIconSet } from '@Lyxal/utils/lib/icon-set/parse';
import { quicklyValidateIconSet } from '@Lyxal/utils/lib/icon-set/validate-basic';
import type {
	LyxalIconCustomisations,
	LyxalIconProps,
	IconProps,
	LyxalRenderMode,
} from './props';
import { render } from './render';

/**
 * Export stuff from props.ts
 */
export { LyxalIconCustomisations, LyxalIconProps, IconProps };

/**
 * Export types that could be used in component
 */
export { LyxalIcon, LyxalJSON, LyxalIconSize, LyxalRenderMode };

/**
 * Storage for icons referred by name
 */
const storage: Record<string, LyxalIcon> = Object.create(null);

/**
 * Add icon to storage, allowing to call it by name
 *
 * @param name
 * @param data
 */
export function addIcon(name: string, data: LyxalIcon): void {
	storage[name] = data;
}

/**
 * Add collection to storage, allowing to call icons by name
 *
 * @param data Icon set
 * @param prefix Optional prefix to add to icon names, true (default) if prefix from icon set should be used.
 */
export function addCollection(
	data: LyxalJSON,
	prefix?: string | boolean
): void {
	const iconPrefix: string =
		typeof prefix === 'string'
			? prefix
			: prefix !== false && typeof data.prefix === 'string'
			? data.prefix + ':'
			: '';
	quicklyValidateIconSet(data) &&
		parseIconSet(data, (name, icon) => {
			if (icon) {
				storage[iconPrefix + name] = icon;
			}
		});
}

/**
 * Component
 */
export const Icon = defineComponent<IconProps>(
	(props: IconProps, ctx) => {
		// Render function
		return () => {
			// Check icon
			const propsIcon = props.icon;
			const icon: LyxalIcon | null =
				typeof propsIcon === 'string'
					? storage[propsIcon]
					: typeof propsIcon === 'object'
					? propsIcon
					: null;

			// Validate icon object
			if (
				icon === null ||
				typeof icon !== 'object' ||
				typeof icon.body !== 'string'
			) {
				// Failed
				return renderSlot(ctx.slots, 'default');
			}

			// Valid icon: render it
			return render(
				{
					...defaultIconProps,
					...icon,
				},
				props
			);
		};
	},
	{
		props: [
			// Icon and render mode
			'icon',
			'mode',
			'ssr',
			// Layout and style
			'width',
			'height',
			'style',
			'color',
			'inline',
			// Transformations
			'rotate',
			'hFlip',
			'horizontalFlip',
			'vFlip',
			'verticalFlip',
			'flip',
			// Misc
			'id',
			'ariaHidden',
			'customise',
			'title',
		],
	}
);
