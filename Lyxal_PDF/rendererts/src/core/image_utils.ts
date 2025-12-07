/* Copyright 2019 Mozilla Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { assert, unreachable, warn } from "../shared/util";
import { Ref, RefSet, RefSetCache } from "./primitives";

declare const PDFJSDev: any;

class BaseLocalCache {
  _onlyRefs: boolean;
  _nameRefMap: Map<string, Ref> | undefined;
  _imageMap: Map<string, any> | undefined;
  _imageCache: RefSetCache<any>;

  constructor(options?: { onlyRefs?: boolean }) {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      this.constructor === BaseLocalCache
    ) {
      unreachable("Cannot initialize BaseLocalCache.");
    }
    this._onlyRefs = options?.onlyRefs === true;

    if (!this._onlyRefs) {
      this._nameRefMap = new Map();
      this._imageMap = new Map();
    }
    this._imageCache = new RefSetCache();
  }

  getByName(name: string) {
    if (this._onlyRefs) {
      unreachable("Should not call `getByName` method.");
    }
    const ref = this._nameRefMap!.get(name);
    if (ref) {
      return this.getByRef(ref);
    }
    return this._imageMap!.get(name) || null;
  }

  getByRef(ref: Ref) {
    return this._imageCache.get(ref) || null;
  }

  set(name: string | null, ref: Ref | null, data: any) {
    unreachable("Abstract method `set` called.");
  }
}

export class LocalImageCache extends BaseLocalCache {
  set(name: string | null, ref: Ref | null = null, data: any) {
    if (typeof name !== "string") {
      throw new Error('LocalImageCache.set - expected "name" argument.');
    }
    if (ref) {
      if (this._imageCache.has(ref)) {
        return;
      }
      this._nameRefMap!.set(name, ref);
      this._imageCache.put(ref, data);
      return;
    }
    // name
    if (this._imageMap!.has(name)) {
      return;
    }
    this._imageMap!.set(name, data);
  }
}

export class LocalColorSpaceCache extends BaseLocalCache {
  set(name: string | null = null, ref: Ref | null = null, data: any) {
    if (typeof name !== "string" && !ref) {
      throw new Error(
        'LocalColorSpaceCache.set - expected "name" and/or "ref" argument.'
      );
    }
    if (ref) {
      if (this._imageCache.has(ref)) {
        return;
      }
      if (name !== null) {
        // Optional when `ref` is defined.
        this._nameRefMap!.set(name, ref);
      }
      this._imageCache.put(ref, data);
      return;
    }
    // name
    if (this._imageMap!.has(name!)) {
      return;
    }
    this._imageMap!.set(name!, data);
  }
}

export class LocalFunctionCache extends BaseLocalCache {
  constructor(options?: any) {
    super({ onlyRefs: true });
  }

  set(name: string | null = null, ref: Ref, data: any) {
    if (!ref) {
      throw new Error('LocalFunctionCache.set - expected "ref" argument.');
    }
    if (this._imageCache.has(ref)) {
      return;
    }
    this._imageCache.put(ref, data);
  }
}

export class LocalGStateCache extends BaseLocalCache {
  set(name: string | null, ref: Ref | null = null, data: any) {
    if (typeof name !== "string") {
      throw new Error('LocalGStateCache.set - expected "name" argument.');
    }
    if (ref) {
      if (this._imageCache.has(ref)) {
        return;
      }
      this._nameRefMap!.set(name, ref);
      this._imageCache.put(ref, data);
      return;
    }
    // name
    if (this._imageMap!.has(name)) {
      return;
    }
    this._imageMap!.set(name, data);
  }
}

export class LocalTilingPatternCache extends BaseLocalCache {
  constructor(options?: any) {
    super({ onlyRefs: true });
  }

  set(name: string | null = null, ref: Ref, data: any) {
    if (!ref) {
      throw new Error('LocalTilingPatternCache.set - expected "ref" argument.');
    }
    if (this._imageCache.has(ref)) {
      return;
    }
    this._imageCache.put(ref, data);
  }
}

export class RegionalImageCache extends BaseLocalCache {
  constructor(options?: any) {
    super({ onlyRefs: true });
  }

  set(name: string | null = null, ref: Ref, data: any) {
    if (!ref) {
      throw new Error('RegionalImageCache.set - expected "ref" argument.');
    }
    if (this._imageCache.has(ref)) {
      return;
    }
    this._imageCache.put(ref, data);
  }
}

export class GlobalColorSpaceCache extends BaseLocalCache {
  constructor(options?: any) {
    super({ onlyRefs: true });
  }

  set(name: string | null = null, ref: Ref, data: any) {
    if (!ref) {
      throw new Error('GlobalColorSpaceCache.set - expected "ref" argument.');
    }
    if (this._imageCache.has(ref)) {
      return;
    }
    this._imageCache.put(ref, data);
  }

  clear() {
    this._imageCache.clear();
  }
}

export class GlobalImageCache {
  static NUM_PAGES_THRESHOLD = 2;

  static MIN_IMAGES_TO_CACHE = 10;

  static MAX_BYTE_SIZE = 5e7; // Fifty megabytes.

  #decodeFailedSet = new RefSet();
  _refCache: RefSetCache<Set<number>>;
  _imageCache: RefSetCache<any>;

  constructor() {
    if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
      assert(
        GlobalImageCache.NUM_PAGES_THRESHOLD > 1,
        "GlobalImageCache - invalid NUM_PAGES_THRESHOLD constant."
      );
    }
    this._refCache = new RefSetCache();
    this._imageCache = new RefSetCache();
  }

  get #byteSize() {
    let byteSize = 0;
    for (const imageData of this._imageCache) {
      byteSize += imageData.byteSize;
    }
    return byteSize;
  }

  get #cacheLimitReached() {
    if (this._imageCache.size < GlobalImageCache.MIN_IMAGES_TO_CACHE) {
      return false;
    }
    if (this.#byteSize < GlobalImageCache.MAX_BYTE_SIZE) {
      return false;
    }
    return true;
  }

  shouldCache(ref: Ref, pageIndex: number) {
    let pageIndexSet = this._refCache.get(ref);
    if (!pageIndexSet) {
      pageIndexSet = new Set();
      this._refCache.put(ref, pageIndexSet);
    }
    pageIndexSet.add(pageIndex);

    if (pageIndexSet.size < GlobalImageCache.NUM_PAGES_THRESHOLD) {
      return false;
    }
    if (!this._imageCache.has(ref) && this.#cacheLimitReached) {
      return false;
    }
    return true;
  }

  addDecodeFailed(ref: Ref) {
    this.#decodeFailedSet.put(ref);
  }

  hasDecodeFailed(ref: Ref) {
    return this.#decodeFailedSet.has(ref);
  }

  /**
   * PLEASE NOTE: Must be called *after* the `setData` method.
   */
  addByteSize(ref: Ref, byteSize: number) {
    const imageData = this._imageCache.get(ref);
    if (!imageData) {
      return; // The image data isn't cached (the limit was reached).
    }
    if (imageData.byteSize) {
      return; // The byte-size has already been set.
    }
    imageData.byteSize = byteSize;
  }

  getData(ref: Ref, pageIndex: number) {
    const pageIndexSet = this._refCache.get(ref);
    if (!pageIndexSet) {
      return null;
    }
    if (pageIndexSet.size < GlobalImageCache.NUM_PAGES_THRESHOLD) {
      return null;
    }
    const imageData = this._imageCache.get(ref);
    if (!imageData) {
      return null;
    }
    // Ensure that we keep track of all pages containing the image reference.
    pageIndexSet.add(pageIndex);

    return imageData;
  }

  setData(ref: Ref, data: any) {
    if (!this._refCache.has(ref)) {
      throw new Error(
        'GlobalImageCache.setData - expected "shouldCache" to have been called.'
      );
    }
    if (this._imageCache.has(ref)) {
      return;
    }
    if (this.#cacheLimitReached) {
      warn("GlobalImageCache.setData - cache limit reached.");
      return;
    }
    this._imageCache.put(ref, data);
  }

  clear(onlyData = false) {
    if (!onlyData) {
      this.#decodeFailedSet.clear();
      this._refCache.clear();
    }
    this._imageCache.clear();
  }
}
