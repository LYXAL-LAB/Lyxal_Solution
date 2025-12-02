import { promises as fs, Stats } from 'fs';
import type { LyxalJSON } from '@lyxal-icon/types';
import { tryInstallPkg } from './install-pkg';
import type { AutoInstall } from './types';
import { resolvePathAsync } from './resolve.js';

/** Cache: [cwd][name] => icon set promise */
type CachedItem = Promise<LyxalJSON | undefined>;
type CachedItems = Record<string, CachedItem>;
const _collections = Object.create(null) as Record<string, CachedItems>;

/** Check if full package exists, per cwd value */
const isLegacyExists = Object.create(null) as Record<string, boolean>;

/**
 * Asynchronously loads a collection from the file system.
 *
 * @param name {string} the name of the collection, e.g. 'mdi'
 * @param autoInstall {AutoInstall} [autoInstall=false] - whether to automatically install
 * @param scope {string} [scope='@Lyxal-json'] - the scope of the collection, e.g. '@my-company-json'
 * @param cwd {string} [cwd=process.cwd()] - current working directory for caching
 * @return {Promise<LyxalJSON | undefined>} the loaded LyxalJSON or undefined
 */
export async function loadCollectionFromFS(
	name: string,
	autoInstall: AutoInstall = false,
	scope = '@lyxal-icon/json',
	cwd = process.cwd()
): Promise<LyxalJSON | undefined> {
	const cache =
		_collections[cwd] ||
		(_collections[cwd] = Object.create(null) as CachedItems);

	if (!(await cache[name])) {
		cache[name] = task();
	}
	return cache[name];

	async function task() {
		const packageName = scope.length === 0 ? name : `${scope}/${name}`;
		let jsonPath = await resolvePathAsync(`${packageName}/icons.json`, cwd);

		// Legacy support for @lyxal-icon/json
		if (scope === '@lyxal-icon/json') {
			// Check legacy package exists
			if (isLegacyExists[cwd] === undefined) {
				const testResult = await resolvePathAsync(
					`@lyxal-icon/json/collections.json`,
					cwd
				);
				isLegacyExists[cwd] = !!testResult;
			}
			const checkLegacy = isLegacyExists[cwd];

			// Check legacy package
			if (!jsonPath && checkLegacy) {
				jsonPath = await resolvePathAsync(
					`@lyxal-icon/json/json/${name}.json`,
					cwd
				);
			}

			// Try to install the package if it doesn't exist
			if (!jsonPath && !checkLegacy && autoInstall) {
				await tryInstallPkg(packageName, autoInstall);
				jsonPath = await resolvePathAsync(
					`${packageName}/icons.json`,
					cwd
				);
			}
		} else if (!jsonPath && autoInstall) {
			await tryInstallPkg(packageName, autoInstall);
			jsonPath = await resolvePathAsync(`${packageName}/icons.json`, cwd);
		}

		// Try to import module if it exists
		if (!jsonPath) {
			let packagePath = await resolvePathAsync(packageName, cwd);
			if (packagePath?.match(/^[a-z]:/i)) {
				packagePath = `file:///${packagePath}`.replace(/\\/g, '/');
			}
			if (packagePath) {
				const { icons }: { icons?: LyxalJSON } = await import(
					packagePath
				);
				if (icons) return icons;
			}
		}

		// Load from file
		let stat: Stats | undefined;
		try {
			stat = jsonPath ? await fs.lstat(jsonPath) : undefined;
			// eslint-disable-next-line @typescript-eslint/no-unused-vars
		} catch (err) {
			return undefined;
		}
		if (stat?.isFile()) {
			return JSON.parse(
				await fs.readFile(jsonPath as string, 'utf8')
			) as LyxalJSON;
		} else {
			return undefined;
		}
	}
}
