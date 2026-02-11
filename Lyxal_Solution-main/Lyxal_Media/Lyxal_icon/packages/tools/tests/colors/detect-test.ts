import type { LyxalJSON } from '@Lyxal/types';
import { IconSet } from '../../src/icon-set/index.js';
import { detectIconSetPalette } from '../../src/colors/detect.js';
import { loadFixture } from '../../src/tests/helpers.js';

describe('Detecting palette', () => {
	test('Empty icon set', () => {
		const iconSetData: LyxalJSON = {
			prefix: 'foo',
			icons: {},
		};
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(null);
	});

	test('Icons with palette', () => {
		const iconSetData: LyxalJSON = {
			prefix: 'foo',
			icons: {
				foo: {
					body: '<g fill="red" />',
				},
				bar: {
					body: '<g fill="green" />',
				},
			},
		};
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(true);
	});

	test('Icons without palette', () => {
		const iconSetData: LyxalJSON = {
			prefix: 'foo',
			icons: {
				foo: {
					body: '<g fill="currentColor" />',
				},
				bar: {
					// lower case
					body: '<g fill="currentcolor" />',
				},
			},
		};
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(false);
	});

	test('Mixed', () => {
		const iconSetData: LyxalJSON = {
			prefix: 'foo',
			icons: {
				foo: {
					body: '<g fill="red" />',
				},
				bar: {
					body: '<g fill="currentColor" />',
				},
			},
		};
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(null);
	});

	test('No colors', () => {
		const iconSetData: LyxalJSON = {
			prefix: 'foo',
			icons: {
				foo: {
					body: '<g />',
				},
			},
		};
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(null);
	});

	test('arty-animated.json', async () => {
		const iconSetData = JSON.parse(
			await loadFixture('arty-animated.json')
		) as LyxalJSON;
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(false);
	});

	test('codicon.json', async () => {
		const iconSetData = JSON.parse(
			await loadFixture('codicon.json')
		) as LyxalJSON;
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(false);
	});

	test('fluent.json', async () => {
		const iconSetData = JSON.parse(
			await loadFixture('fluent.new.json')
		) as LyxalJSON;
		const iconSet = new IconSet(iconSetData);

		expect(detectIconSetPalette(iconSet)).toBe(false);
	});
});
