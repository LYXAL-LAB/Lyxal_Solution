import type { LyxalIcon } from '@lyxal-icon/types';
import type { SVGAttributes } from 'vue';

export interface CSSIconComponentViewbox {
	left?: number;
	top?: number;
	width: number;
	height: number;
}

export interface CSSIconComponentProps {
	// Size
	width?: string;
	height?: string;

	// viewBox
	viewBox: CSSIconComponentViewbox;

	// Raw content to render if browser supports SVG+CSS
	content?: string | LyxalIcon;

	// Fallback icon name
	fallback?: string | LyxalIcon;
}

// SVG properties
export interface CSSIconElementProps
	extends CSSIconComponentProps,
	Omit<SVGAttributes, 'viewBox' | 'width' | 'height' | 'xmlns'> {
	//
}
