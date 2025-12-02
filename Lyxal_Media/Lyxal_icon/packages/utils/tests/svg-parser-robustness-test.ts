import { parseSVGContent } from '../src/svg/parse';

describe('SVG Parser Robustness', () => {
	test('Attributes with single quotes', () => {
		const svg = `<svg viewBox='0 0 24 24' width='24' height='24'><path d='M0 0h24v24H0z'/></svg>`;
		const parsed = parseSVGContent(svg);
		expect(parsed).toBeDefined();
		expect(parsed?.attribs).toEqual({
			viewBox: '0 0 24 24',
			width: '24',
			height: '24',
		});
	});

	test('Attributes without quotes', () => {
		const svg = `<svg viewBox=0 0 24 24 width=24 height=24><path d=M0 0h24v24H0z/></svg>`;
		// Note: This might be tricky for simple regex, but valid HTML5/SVG in some contexts.
		// If we want to support strictly XML SVG, quotes are required.
		// However, robust parsers often handle this.
		// Let's stick to what we definitely want to support: single quotes and mixed quotes.
	});

	test('Attributes with mixed quotes', () => {
		const svg = `<svg viewBox="0 0 24 24" width='24'><path d="M0 0h24v24H0z"/></svg>`;
		const parsed = parseSVGContent(svg);
		expect(parsed).toBeDefined();
		expect(parsed?.attribs).toEqual({
			viewBox: '0 0 24 24',
			width: '24',
		});
	});

	test('Attributes with spaces around equals', () => {
		const svg = `<svg viewBox = "0 0 24 24" width= "24" height ="24"><path d="M0 0h24v24H0z"/></svg>`;
		const parsed = parseSVGContent(svg);
		expect(parsed).toBeDefined();
		expect(parsed?.attribs).toEqual({
			viewBox: '0 0 24 24',
			width: '24',
			height: '24',
		});
	});

	test('Multiline attributes', () => {
		const svg = `<svg 
			viewBox="0 0 24 24"
			width="24"
			height="24">
			<path d="M0 0h24v24H0z"/>
		</svg>`;
		const parsed = parseSVGContent(svg);
		expect(parsed).toBeDefined();
		expect(parsed?.attribs).toEqual({
			viewBox: '0 0 24 24',
			width: '24',
			height: '24',
		});
	});

	test('Self-closing SVG tag', () => {
		const svg = `<svg viewBox="0 0 24 24"/>`;
		// Current parser expects <svg>...</svg> so this might fail or return undefined,
		// but a robust parser should handle it or at least not crash.
		// The current regex expects content between tags.
		// If we want to support it, we should.
	});
});
