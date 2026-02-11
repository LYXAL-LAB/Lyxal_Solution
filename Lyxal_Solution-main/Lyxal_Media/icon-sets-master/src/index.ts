/**
 * This file is part of the Lyxal.design libraries.
 *
 * (c) Vjacheslav Trushkin <cyberalien@gmail.com>
 *
 * @license MIT
 *
 * For the full copyright and license information, please view the license.txt
 * file that is available in this file's directory.
 */
import type { PathLike } from 'fs';
import { promises as fs } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'pathe';
import type { LyxalInfo, LyxalJSON } from '@Lyxal/types';

/**
 * Collection info map
 */
export type LyxalMetaDataCollection = {
  [prefix: string]: LyxalInfo;
};

const _dirname =
  typeof __dirname !== 'undefined'
    ? __dirname
    : dirname(fileURLToPath(import.meta.url));

/**
 * Directory of this package
 */
export const dir = join(_dirname, '/..');

/**
 * Locate JSON file
 *
 * @param {string} name Collection name
 * @returns {string} Path to collection json file
 */
export const locate = (name: string): PathLike =>
  join(dir, `./json/${name}.json`);

/**
 * Loads a collection.
 *
 * @param {PathLike} path The path to locate the `json` collection file.
 * @return {Promise<LyxalJSON>}
 */
export const loadCollection = async (path: PathLike): Promise<LyxalJSON> => {
  return JSON.parse(await fs.readFile(path, 'utf8'));
};

/**
 * Get a collection.
 *
 * @param {string} name The name of the collection
 * @return {Promise<LyxalJSON>}
 */
export const lookupCollection = async (name: string): Promise<LyxalJSON> => {
  return await loadCollection(locate(name));
};

/**
 * Get list of collections info.
 *
 * @return {Promise<LyxalMetaDataCollection>}
 */
export const lookupCollections =
  async (): Promise<LyxalMetaDataCollection> => {
    return JSON.parse(
      await fs.readFile(join(dir, './collections.json'), 'utf8')
    );
  };
