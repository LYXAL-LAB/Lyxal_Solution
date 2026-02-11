import { renderContent } from '../src/helpers/content.js';

describe('Testing rendering icon', () => {
	it('Render string', () => {
		expect(renderContent('<g />')).toBe('<g />');
	});

	it('Render LyxalIcon', () => {
		expect(
			renderContent({
				body: '<g />',
				width: 16,
				height: 16,
			})
		).toBe('<g />');
	});
});
