import { forwardRef, createElement, memo } from 'react';
import type { Ref, JSX } from 'react';
import type { LyxalIcon, LyxalJSON } from '@lyxal-icon/types';
import type { LyxalIconSize } from '@lyxal-icon/utils/lib/customisations/defaults';
import { defaultIconProps } from '@lyxal-icon/utils/lib/icon/defaults';
import { parseIconSet } from '@lyxal-icon/utils/lib/icon-set/parse';
import { quicklyValidateIconSet } from '@lyxal-icon/utils/lib/icon-set/validate-basic';
import type {
	LyxalIconCustomisations,
	LyxalIconProps,
	LyxalRenderMode,
	IconProps,
	IconElement,
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
 * Component
 */
interface InternalIconProps extends IconProps {
	_ref?: Ref<IconElement> | null;
}

function IconComponent(props: InternalIconProps): JSX.Element {
	const icon = props.icon;
	const data = typeof icon === 'string' ? storage[icon] : icon;

	if (!data) {
		return props.children
			? (props.children as JSX.Element)
			: createElement('span', {});
	}

	return render(
		{
			...defaultIconProps,
			...data,
		},
		props,
		typeof icon === 'string' ? icon : undefined
	);
}

// Component type
type IconComponentType = (props: IconProps) => JSX.Element;

/**
 * Block icon
 *
 * @param props - Component properties
 */
export const Icon = memo(
	forwardRef<IconElement, IconProps>((props, ref) =>
		IconComponent({
			...props,
			_ref: ref,
		})
	)
) as IconComponentType;

/**
 * Inline icon (has negative verticalAlign that makes it behave like icon font)
 *
 * @param props - Component properties
 */
export const InlineIcon = memo(
	forwardRef<IconElement, IconProps>((props, ref) =>
		IconComponent({
			inline: true,
			...props,
			_ref: ref,
		})
	)
) as IconComponentType;

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
