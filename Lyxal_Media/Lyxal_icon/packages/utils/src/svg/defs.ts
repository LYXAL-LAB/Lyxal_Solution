import { parseXMLContent } from '../xml/parse.js';
import { stringifyXMLContent } from '../xml/stringify.js';

interface SplitSVGDefsResult {
	defs: string;
	content: string;
}

/**
 * Extract definitions from SVG
 *
 * Can be used with other tags, but name kept for backwards compatibility.
 * Should be used only with tags that cannot be nested, such as masks, clip paths, etc.
 */
export function splitSVGDefs(
	content: string,
	tag = 'defs'
): SplitSVGDefsResult {
	const parsed = parseXMLContent(content);
	if (!parsed) {
		// Failed to parse: return as is
		return {
			defs: '',
			content,
		};
	}

	let defs = '';
	let newContent = '';

	const check = (nodes: typeof parsed) => {
		for (const node of nodes) {
			if (node.type === 'tag' && node.tag === tag) {
				// Found definitions
				defs += stringifyXMLContent(node.children);
				continue;
		}
			newContent += stringifyXMLContent([node]);
		}
	};
	
	check(parsed);

	return {
		defs,
		content: newContent,
	};
}

/**
 * Merge defs and content
 */
export function mergeDefsAndContent(defs: string, content: string): string {
	return defs ? '<defs>' + defs + '</defs>' + content : content;
}

/**
 * Wrap SVG content, without wrapping definitions
 */
export function wrapSVGContent(
	body: string,
	start: string,
	end: string
): string {
	const split = splitSVGDefs(body);
	return mergeDefsAndContent(split.defs, start + split.content + end);
}
