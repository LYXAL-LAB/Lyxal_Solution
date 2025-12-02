import { LyxalIcon } from '@lyxal-icon/types';
import { LyxalIconBuildResult } from './build';
import { wrapSVGContent } from './defs';
import { SVGViewBox, getSVGViewBox } from './viewbox';

/**
 * Parsed SVG content
 */
export interface ParsedSVGContent {
	// Attributes for SVG element
	attribs: Record<string, string>;

	// Content
	body: string;
}

/**
 * Extract attributes and content from SVG
 */
export function parseSVGContent(content: string): ParsedSVGContent | undefined {
	// Simple state machine to parse SVG
	let index = 0;
	const length = content.length;

	// Skip whitespace
	function skipWhitespace() {
		while (index < length && /\s/.test(content[index])) {
			index++;
		}
	}

	// Find start of SVG tag
	const svgStartRegex = /<svg\s*/i;
	const match = content.match(svgStartRegex);
	if (!match) {
		return;
	}
	index = (match.index || 0) + match[0].length;

	// Parse attributes
	const attribs = Object.create(null) as Record<string, string>;
	let openQuote: string | null = null;
	let attrName = '';
	let attrValue = '';
	let state: 'name' | 'equals' | 'value' | 'whitespace' = 'name';

	while (index < length) {
		const char = content[index];

		// Check for end of tag
		if (state !== 'value' && (char === '>' || (char === '/' && content[index + 1] === '>'))) {
			if (attrName) {
				// Attribute without value
				attribs[attrName] = attrName;
			}
			break;
		}

		if (state === 'name') {
			if (char === '=') {
				state = 'equals';
				index++;
				continue;
			}
			if (/\s/.test(char)) {
				if (attrName) {
					// Attribute without value or space before equals
					state = 'whitespace';
				}
				index++;
				continue;
			}
			attrName += char;
			index++;
			continue;
		}

		if (state === 'whitespace') {
			if (char === '=') {
				state = 'equals';
				index++;
				continue;
			}
			if (/\s/.test(char)) {
				index++;
				continue;
			}
			// Start of new attribute
			if (attrName) {
				attribs[attrName] = attrName;
			}
			attrName = char;
			state = 'name';
			index++;
			continue;
		}

		if (state === 'equals') {
			if (/\s/.test(char)) {
				index++;
				continue;
			}
			if (char === '"' || char === "'") {
				openQuote = char;
				state = 'value';
				index++;
				continue;
			}
			// Unquoted value
			openQuote = null;
			state = 'value';
			continue; // Do not increment index, let value parser handle it
		}

		if (state === 'value') {
			if (openQuote) {
				if (char === openQuote) {
					attribs[attrName] = attrValue;
					attrName = '';
					attrValue = '';
					state = 'whitespace';
					index++;
					continue;
				}
				attrValue += char;
				index++;
				continue;
			} else {
				// Unquoted value
				if (/\s/.test(char) || char === '>' || (char === '/' && content[index + 1] === '>')) {
					attribs[attrName] = attrValue;
					attrName = '';
					attrValue = '';
					state = 'whitespace';
					// Do not increment index if it's end of tag, let loop condition handle it
					if (char === '>' || char === '/') {
						continue;
					}
					index++;
					continue;
				}
				attrValue += char;
				index++;
				continue;
			}
		}
	}

	// Find end of open tag
	const closeIndex = content.indexOf('>', index);
	if (closeIndex === -1) {
		return;
	}
	const bodyStart = closeIndex + 1;

	// Find closing tag
	const closingTag = '</svg>';
	const bodyEnd = content.lastIndexOf(closingTag);
	if (bodyEnd === -1 || bodyEnd < bodyStart) {
		// Self-closing or invalid
		if (content.substring(index, index + 2) === '/>') {
			return {
				attribs,
				body: '',
			};
		}
		return;
	}

	const body = content.slice(bodyStart, bodyEnd).trim();

	return {
		attribs,
		body,
	};
}

interface BuildResult {
	width?: string;
	height?: string;
	viewBox: SVGViewBox;
	body: string;
}

function build(data: ParsedSVGContent): BuildResult | undefined {
	const attribs = data.attribs;
	const viewBox = getSVGViewBox(attribs['viewBox'] ?? '');
	if (!viewBox) {
		return;
	}

	// Split presentation attributes
	const groupAttributes: string[] = [];
	for (const key in attribs) {
		if (
			key === 'style' ||
			key.startsWith('fill') ||
			key.startsWith('stroke')
		) {
			groupAttributes.push(`${key}="${attribs[key]}"`);
		}
	}

	let body = data.body;
	if (groupAttributes.length) {
		// Wrap content in group, except for defs
		body = wrapSVGContent(
			body,
			'<g ' + groupAttributes.join(' ') + '>',
			'</g>'
		);
	}

	return {
		// Copy dimensions if exist
		width: attribs.width,
		height: attribs.height,
		viewBox,
		body,
	};
}

/**
 * Convert parsed SVG to LyxalIconBuildResult
 */
export function buildParsedSVG(
	data: ParsedSVGContent
): LyxalIconBuildResult | undefined {
	const result = build(data);
	if (result) {
		return {
			attributes: {
				// Copy dimensions if exist
				width: result.width,
				height: result.height,
				// Merge viewBox
				viewBox: result.viewBox.join(' '),
			},
			viewBox: result.viewBox,
			body: result.body,
		};
	}
}

/**
 * Convert parsed SVG to LyxalIcon
 */
export function convertParsedSVG(
	data: ParsedSVGContent
): LyxalIcon | undefined {
	const result = build(data);
	if (result) {
		const viewBox = result.viewBox;
		return {
			left: viewBox[0],
			top: viewBox[1],
			width: viewBox[2],
			height: viewBox[3],
			body: result.body,
		};
	}
}
