import type {
	ParsedXMLNode,
	ParsedXMLTagElement,
	StringifyXMLOptions,
} from './types.js';

/**
 * Stringify XML
 */
export function stringifyXMLContent(
	tree: ParsedXMLNode[],
	options: StringifyXMLOptions = {}
): string {
	const result: string[] = [];
	const useSelfClosing = options.useSelfClosing !== false;
	const numberTemplate = options.numberTemplate || '{num}';
	const prettyPrint = options.prettyPrint;
	const tab = typeof prettyPrint === 'string' ? prettyPrint : '\t';

	function parse(item: ParsedXMLNode, depth: number) {
		const prefix = prettyPrint ? Array(depth).fill(tab).join('') : '';

		if (item.type === 'text') {
			const text = item.content.trim();
			if (text) {
				result.push(prefix + text);
			}
			return;
		}

		const attribs = item.attribs;
		const tagName = item.tag;
		let line = prefix + '<' + tagName;

		// Add attributes
		for (const key in attribs) {
			let value = attribs[key];
			if (typeof value === 'number') {
				value = numberTemplate.replace(
					'{num}',
					(Math.round(value * 1000) / 1000).toString()
				);
			}
			line += ' ' + key + '="' + value + '"';
		}

		// Check for children
		if (!item.children.length) {
			if (useSelfClosing) {
				line += ' />';
				result.push(line);
				return;
			}
			line += '></' + tagName + '>';
			result.push(line);
			return;
		}

		line += '>';
		result.push(line);

		// Children
		item.children.forEach((child) => {
			parse(child, depth + 1);
		});

		result.push(prefix + '</' + tagName + '>');
	}

	tree.forEach((item) => {
		parse(item, 0);
	});

	return result.join(prettyPrint ? '\n' : '');
}

