import { createLyxalAPILoader } from './create.js';
import { setProviderLoader } from '../loaders.js';

// Add default loader for Lyxal API
setProviderLoader(
	'',
	createLyxalAPILoader([
		'https://api.Lyxal.design',
		'https://api.simplesvg.com',
		'https://api.unisvg.com',
	])
);
