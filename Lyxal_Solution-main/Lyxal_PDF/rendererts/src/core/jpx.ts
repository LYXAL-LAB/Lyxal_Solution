/* Copyright 2024 Mozilla Foundation
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

import { BaseException, warn } from "../shared/util";
import { fetchBinaryData } from "./core_utils";
// @ts-ignore: External dependency handling strategy to be defined properly later
import OpenJPEG from "../../external/openjpeg/openjpeg.js";
import { Stream } from "./stream";

// Define strict types for the OpenJPEG module interface
interface OpenJPEGModule {
  _malloc(size: number): number;
  _free(ptr: number): void;
  writeArrayToMemory(array: Uint8Array, ptr: number): void;
  _jp2_decode(
    ptr: number,
    size: number,
    numComponents: number,
    isIndexedColormap: boolean,
    smaskInData: boolean,
    reducePower: number
  ): number;
  imageData: any; // The decoded data structure
  errorMessages?: string[];
}

export class JpxError extends BaseException {
  constructor(msg: string) {
    super(msg, "JpxError");
  }
}

export class JpxImage {
  static #buffer: Uint8Array | null = null;
  static #handler: any = null;
  static #modulePromise: Promise<OpenJPEGModule> | null = null;
  static #useWasm = true;
  static #useWorkerFetch = true;
  static #wasmUrl: string | null = null;

  static setOptions({
    handler,
    useWasm,
    useWorkerFetch,
    wasmUrl,
  }: {
    handler: any;
    useWasm: boolean;
    useWorkerFetch: boolean;
    wasmUrl: string;
  }) {
    this.#useWasm = useWasm;
    this.#useWorkerFetch = useWorkerFetch;
    this.#wasmUrl = wasmUrl;

    if (!useWorkerFetch) {
      this.#handler = handler;
    }
  }

  static async #getJsModule(fallbackCallback: (instance: any) => void) {
    const path = `${this.#wasmUrl}openjpeg_nowasm_fallback.js`;

    let instance = null;
    try {
      // Dynamic import wrapper to avoid TS errors on non-standard import logic if needed
      // For now using standard dynamic import
      const mod = await import(path);
      instance = mod.default();
    } catch (e) {
      warn(`JpxImage#getJsModule: ${e}`);
    }
    fallbackCallback(instance);
  }

  static async #instantiateWasm(
    fallbackCallback: (instance: any) => void,
    imports: any,
    successCallback: (instance: any) => void
  ) {
    const filename = "openjpeg.wasm";
    try {
      if (!this.#buffer) {
        if (this.#useWorkerFetch) {
          this.#buffer = await fetchBinaryData(`${this.#wasmUrl}${filename}`);
        } else {
          this.#buffer = await this.#handler.sendWithPromise(
            "FetchBinaryData",
            { type: "wasmFactory", filename }
          );
        }
      }
      const results = await WebAssembly.instantiate(this.#buffer!, imports);
      return successCallback(results.instance);
    } catch (reason) {
      warn(`JpxImage#instantiateWasm: ${reason}`);

      this.#getJsModule(fallbackCallback);
      return null;
    } finally {
      this.#handler = null;
    }
  }

  static async decode(
    bytes: Uint8Array,
    {
      numComponents = 4,
      isIndexedColormap = false,
      smaskInData = false,
      reducePower = 0,
    } = {}
  ) {
    if (!this.#modulePromise) {
      // Polyfill Promise.withResolvers logic
      let resolve: (value: OpenJPEGModule | PromiseLike<OpenJPEGModule>) => void;
      // @ts-ignore
      let reject;
      const promise = new Promise<OpenJPEGModule>((res, rej) => {
        resolve = res;
        reject = rej;
      });

      const promises: any[] = [promise];
      if (!this.#useWasm) {
        this.#getJsModule(resolve!);
      } else {
        promises.push(
          OpenJPEG({
            warn,
            instantiateWasm: this.#instantiateWasm.bind(this, resolve!),
          })
        );
      }
      this.#modulePromise = Promise.race(promises);
    }
    const module = await this.#modulePromise;

    if (!module) {
      throw new JpxError("OpenJPEG failed to initialize");
    }
    let ptr: number | undefined;

    try {
      const size = bytes.length;
      ptr = module._malloc(size);
      module.writeArrayToMemory(bytes, ptr);
      const ret = module._jp2_decode(
        ptr,
        size,
        numComponents > 0 ? numComponents : 0,
        !!isIndexedColormap,
        !!smaskInData,
        reducePower
      );
      if (ret) {
        const { errorMessages } = module;
        if (errorMessages) {
          delete module.errorMessages;
          throw new JpxError(errorMessages.join(", "));
        }
        throw new JpxError("Unknown error");
      }
      const { imageData } = module;
      module.imageData = null;

      return imageData;
    } finally {
      if (ptr) {
        module._free(ptr);
      }
    }
  }

  static cleanup() {
    this.#modulePromise = null;
  }

  static parseImageProperties(stream: Stream | Uint8Array | ArrayBuffer) {
    let s: Stream;
    if (stream instanceof Stream) {
        s = stream;
    } else if (stream instanceof ArrayBuffer || ArrayBuffer.isView(stream)) {
      const buffer = stream as Uint8Array | ArrayBuffer;
      const length = (buffer as any).byteLength;
      s = new Stream(buffer, 0, length, null);
    } else {
        throw new JpxError("Invalid data format, must be a Stream or TypedArray.");
    }

    // No need to use OpenJPEG here since we're only getting very basic
    // information which are located in the first bytes of the file.
    let newByte = s.getByte();
    while (newByte >= 0) {
      const oldByte = newByte;
      newByte = s.getByte();
      const code = (oldByte << 8) | newByte;
      // Image and tile size (SIZ)
      if (code === 0xff51) {
        s.skip(4);
        const Xsiz = s.getInt32() >>> 0; // Byte 4
        const Ysiz = s.getInt32() >>> 0; // Byte 8
        const XOsiz = s.getInt32() >>> 0; // Byte 12
        const YOsiz = s.getInt32() >>> 0; // Byte 16
        s.skip(16);
        const Csiz = s.getUint16(); // Byte 36
        return {
          width: Xsiz - XOsiz,
          height: Ysiz - YOsiz,
          // Results are always returned as `Uint8ClampedArray`s.
          bitsPerComponent: 8,
          componentsCount: Csiz,
        };
      }
    }
    throw new JpxError("No size marker found in JPX stream");
  }
}
