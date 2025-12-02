import { iconLoaded } from '@lyxal-icon/core/lib/storage/functions';
import { loadIcon } from '@lyxal-icon/core/lib/api/icons';
import { defaultIconProps } from '@lyxal-icon/utils/lib/icon/defaults';
import { fakeAPI, nextPrefix, mockAPIData } from '../src/tests/helpers';

describe('Testing mock API', () => {
	it('Setting up API', async () => {
		// Set config
		const provider = nextPrefix();
		const prefix = nextPrefix();
		fakeAPI(provider);

		// Mock data
		const name = 'mock-test';
		const iconName = `@${provider}:${prefix}:${name}`;

		mockAPIData({
			type: 'icons',
			provider,
			prefix,
			response: {
				prefix,
				icons: {
					[name]: {
						body: '<g />',
					},
				},
			},
		});

		// Check if icon has been loaded
		expect(iconLoaded(iconName)).toBe(false);

		// Load icon
		const data = await loadIcon(iconName);
		expect(data).toEqual({
			...defaultIconProps,
			body: '<g />',
		});
	});
});
