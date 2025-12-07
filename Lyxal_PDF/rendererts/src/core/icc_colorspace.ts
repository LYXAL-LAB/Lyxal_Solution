/* Copyright 2025 Mozilla Foundation
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

import {
  DataType,
  initSync,
  Intent,
  qcms_convert_array,
  qcms_convert_four,
  qcms_convert_one,
  qcms_convert_three,
  qcms_drop_transformer,
  qcms_transformer_from_memory,
} from "../../external/qcms/qcms.js";
import { shadow, Util, warn } from "../shared/util";
import { ColorSpace } from "./colorspace";
import { QCMS } from "../../external/qcms/qcms_utils.js";

function fetchSync(url: string): ArrayBuffer {
  // Parsing and using color spaces is still synchronous,
  // so we must load the wasm module synchronously.
  // TODO: Make the color space stuff asynchronous and use fetch.
  const xhr = new XMLHttpRequest();
  xhr.open("GET", url, false);
  xhr.responseType = "arraybuffer";
  xhr.send(null);
  return xhr.response;
}

export class IccColorSpace extends ColorSpace {
  #transformer: any;

  #convertPixel: (src: any, srcOffset: number, css: boolean) => void;

  static #useWasm = true;

  static #wasmUrl: string | null = null;

  static #finalizer: FinalizationRegistry<any> | null = null;

  static _module: any;

  constructor(iccProfile: Uint8Array, name: string, numComps: number) {
    if (!IccColorSpace.isUsable) {
      throw new Error("No ICC color space support");
    }

    super(name, numComps);

    let inType;
    switch (numComps) {
      case 1:
        inType = DataType.Gray8;
        this.#convertPixel = (src, srcOffset, css) =>
          qcms_convert_one(this.#transformer, src[srcOffset] * 255, css);
        break;
      case 3:
        inType = DataType.RGB8;
        this.#convertPixel = (src, srcOffset, css) =>
          qcms_convert_three(
            this.#transformer,
            src[srcOffset] * 255,
            src[srcOffset + 1] * 255,
            src[srcOffset + 2] * 255,
            css
          );
        break;
      case 4:
        inType = DataType.CMYK;
        this.#convertPixel = (src, srcOffset, css) =>
          qcms_convert_four(
            this.#transformer,
            src[srcOffset] * 255,
            src[srcOffset + 1] * 255,
            src[srcOffset + 2] * 255,
            src[srcOffset + 3] * 255,
            css
          );
        break;
      default:
        throw new Error(`Unsupported number of components: ${numComps}`);
    }
    this.#transformer = qcms_transformer_from_memory(
      iccProfile,
      inType,
      Intent.Perceptual
    );
    if (!this.#transformer) {
      throw new Error("Failed to create ICC color space");
    }
    IccColorSpace.#finalizer ||= new FinalizationRegistry(transformer => {
      qcms_drop_transformer(transformer);
    });
    IccColorSpace.#finalizer!.register(this, this.#transformer);
  }

  getRgbHex(src: any, srcOffset: number): string {
    this.#convertPixel(src, srcOffset, /* css */ true);
    return (QCMS as any)._cssColor;
  }

  getRgbItem(src: any, srcOffset: number, dest: any, destOffset: number) {
    (QCMS as any)._destBuffer = dest;
    (QCMS as any)._destOffset = destOffset;
    (QCMS as any)._destLength = 3;
    this.#convertPixel(src, srcOffset, /* css */ false);
    (QCMS as any)._destBuffer = null;
  }

  getRgbBuffer(src: any, srcOffset: number, count: number, dest: any, destOffset: number, bits: number, alpha01: number) {
    src = src.subarray(srcOffset, srcOffset + count * this.numComps!);
    if (bits !== 8) {
      const scale = 255 / ((1 << bits) - 1);
      for (let i = 0, ii = src.length; i < ii; i++) {
        src[i] *= scale;
      }
    }
    (QCMS as any)._mustAddAlpha = alpha01 && dest.buffer === src.buffer;
    (QCMS as any)._destBuffer = dest;
    (QCMS as any)._destOffset = destOffset;
    (QCMS as any)._destLength = count * (3 + alpha01);
    qcms_convert_array(this.#transformer, src);
    (QCMS as any)._mustAddAlpha = false;
    (QCMS as any)._destBuffer = null;
  }

  getOutputLength(inputLength: number, alpha01: number) {
    return ((inputLength / this.numComps!) * (3 + alpha01)) | 0;
  }

  static setOptions({ useWasm, useWorkerFetch, wasmUrl }: { useWasm: boolean; useWorkerFetch: boolean; wasmUrl: string }) {
    if (!useWorkerFetch) {
      this.#useWasm = false;
      return;
    }
    this.#useWasm = useWasm;
    this.#wasmUrl = wasmUrl;
  }

  static get isUsable(): boolean {
    let isUsable = false;
    if (this.#useWasm) {
      if (this.#wasmUrl) {
        try {
          this._module = initSync({
            module: fetchSync(`${this.#wasmUrl}qcms_bg.wasm`),
          });
          isUsable = !!this._module;
          (QCMS as any)._memory = this._module.memory;
          (QCMS as any)._makeHexColor = Util.makeHexColor;
        } catch (e) {
          warn(`ICCBased color space: "${e}".`);
        }
      } else {
        warn("No ICC color space support due to missing `wasmUrl` API option");
      }
    }

    return shadow(this, "isUsable", isUsable);
  }
}

export class CmykICCBasedCS extends IccColorSpace {
  static #iccUrl: string | null = null;

  constructor() {
    const iccProfile = new Uint8Array(
      fetchSync(`${CmykICCBasedCS.#iccUrl}CGATS001Compat-v2-micro.icc`)
    );
    super(iccProfile, "DeviceCMYK", 4);
  }

  static setOptions({ iccUrl }: { iccUrl: string }) {
    this.#iccUrl = iccUrl;
  }

  static get isUsable(): boolean {
    let isUsable = false;
    if (IccColorSpace.isUsable) {
      if (this.#iccUrl) {
        isUsable = true;
      } else {
        warn("No CMYK ICC profile support due to missing `iccUrl` API option");
      }
    }

    return shadow(this, "isUsable", isUsable);
  }
}
