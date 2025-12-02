import type { LyxalIcon } from '@lyxal-icon/types';

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
