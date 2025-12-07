/* Copyright 2012 Mozilla Foundation
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

import { arrayBuffersToBytes, MissingDataException } from "./core_utils";
import { assert } from "../shared/util";
import { Stream } from "./stream";

declare const PDFJSDev: any;

export class ChunkedStream extends Stream {
  chunkSize: number;
  _loadedChunks: Set<number>;
  numChunks: number;
  manager: ChunkedStreamManager;
  progressiveDataLength: number;
  lastSuccessfulEnsureByteChunk: number;

  constructor(length: number, chunkSize: number, manager: ChunkedStreamManager) {
    super(
      /* arrayBuffer = */ new Uint8Array(length),
      /* start = */ 0,
      /* length = */ length,
      /* dict = */ null
    );

    this.chunkSize = chunkSize;
    this._loadedChunks = new Set();
    this.numChunks = Math.ceil(length / chunkSize);
    this.manager = manager;
    this.progressiveDataLength = 0;
    this.lastSuccessfulEnsureByteChunk = -1; // Single-entry cache
  }

  // If a particular stream does not implement one or more of these methods,
  // an error should be thrown.
  getMissingChunks() {
    const chunks = [];
    for (let chunk = 0, n = this.numChunks; chunk < n; ++chunk) {
      if (!this._loadedChunks.has(chunk)) {
        chunks.push(chunk);
      }
    }
    return chunks;
  }

  get numChunksLoaded() {
    return this._loadedChunks.size;
  }

  get isDataLoaded() {
    return this.numChunksLoaded === this.numChunks;
  }

  onReceiveData(begin: number, chunk: any) {
    const chunkSize = this.chunkSize;
    if (begin % chunkSize !== 0) {
      throw new Error(`Bad begin offset: ${begin}`);
    }

    // Using `this.length` is inaccurate here since `this.start` can be moved
    // (see the `moveStart` method).
    const end = begin + chunk.byteLength;
    if (end % chunkSize !== 0 && end !== this.bytes.length) {
      throw new Error(`Bad end offset: ${end}`);
    }

    this.bytes.set(new Uint8Array(chunk), begin);
    const beginChunk = Math.floor(begin / chunkSize);
    const endChunk = Math.floor((end - 1) / chunkSize) + 1;

    for (let curChunk = beginChunk; curChunk < endChunk; ++curChunk) {
      // Since a value can only occur *once* in a `Set`, there's no need to
      // manually check `Set.prototype.has()` before adding the value here.
      this._loadedChunks.add(curChunk);
    }
  }

  onReceiveProgressiveData(data: any) {
    let position = this.progressiveDataLength;
    const beginChunk = Math.floor(position / this.chunkSize);

    this.bytes.set(new Uint8Array(data), position);
    position += data.byteLength;
    this.progressiveDataLength = position;
    const endChunk =
      position >= this.end
        ? this.numChunks
        : Math.floor(position / this.chunkSize);

    for (let curChunk = beginChunk; curChunk < endChunk; ++curChunk) {
      // Since a value can only occur *once* in a `Set`, there's no need to
      // manually check `Set.prototype.has()` before adding the value here.
      this._loadedChunks.add(curChunk);
    }
  }

  ensureByte(pos: number) {
    if (pos < this.progressiveDataLength) {
      return;
    }

    const chunk = Math.floor(pos / this.chunkSize);
    if (chunk > this.numChunks) {
      return;
    }
    if (chunk === this.lastSuccessfulEnsureByteChunk) {
      return;
    }

    if (!this._loadedChunks.has(chunk)) {
      throw new MissingDataException(pos, pos + 1);
    }
    this.lastSuccessfulEnsureByteChunk = chunk;
  }

  ensureRange(begin: number, end: number) {
    if (begin >= end) {
      return;
    }
    if (end <= this.progressiveDataLength) {
      return;
    }

    const beginChunk = Math.floor(begin / this.chunkSize);
    if (beginChunk > this.numChunks) {
      return;
    }
    const endChunk = Math.min(
      Math.floor((end - 1) / this.chunkSize) + 1,
      this.numChunks
    );
    for (let chunk = beginChunk; chunk < endChunk; ++chunk) {
      if (!this._loadedChunks.has(chunk)) {
        throw new MissingDataException(begin, end);
      }
    }
  }

  nextEmptyChunk(beginChunk: number) {
    const numChunks = this.numChunks;
    for (let i = 0; i < numChunks; ++i) {
      const chunk = (beginChunk + i) % numChunks; // Wrap around to beginning.
      if (!this._loadedChunks.has(chunk)) {
        return chunk;
      }
    }
    return null;
  }

  hasChunk(chunk: number) {
    return this._loadedChunks.has(chunk);
  }

  getByte() {
    const pos = this.pos;
    if (pos >= this.end) {
      return -1;
    }
    if (pos >= this.progressiveDataLength) {
      this.ensureByte(pos);
    }
    return this.bytes[this.pos++];
  }

  getBytes(length?: number) {
    const bytes = this.bytes;
    const pos = this.pos;
    const strEnd = this.end;

    if (!length) {
      if (strEnd > this.progressiveDataLength) {
        this.ensureRange(pos, strEnd);
      }
      return bytes.subarray(pos, strEnd);
    }

    let end = pos + length;
    if (end > strEnd) {
      end = strEnd;
    }
    if (end > this.progressiveDataLength) {
      this.ensureRange(pos, end);
    }

    this.pos = end;
    return bytes.subarray(pos, end);
  }

  getByteRange(begin: number, end: number) {
    if (begin < 0) {
      begin = 0;
    }
    if (end > this.end) {
      end = this.end;
    }
    if (end > this.progressiveDataLength) {
      this.ensureRange(begin, end);
    }
    return this.bytes.subarray(begin, end);
  }

  makeSubStream(start: number, length: number, dict = null) {
    if (length) {
      if (start + length > this.progressiveDataLength) {
        this.ensureRange(start, start + length);
      }
    } else if (start >= this.progressiveDataLength) {
      // When the `length` is undefined you do *not*, under any circumstances,
      // want to fallback on calling `this.ensureRange(start, this.end)` since
      // that would force the *entire* PDF file to be loaded, thus completely
      // breaking the whole purpose of using streaming and/or range requests.
      //
      // However, not doing any checking here could very easily lead to wasted
      // time/resources during e.g. parsing, since `MissingDataException`s will
      // require data to be re-parsed, which we attempt to minimize by at least
      // checking that the *beginning* of the data is available here.
      this.ensureByte(start);
    }

    // In TypeScript, we can't easily inherit and override prototype properties
    // dynamically like in JS. We'll use a class extension or just return a new
    // instance with modified behavior if possible, or use the JS pattern with casts.
    
    // Using an anonymous class or a helper class.
    class ChunkedStreamSubstream extends ChunkedStream {
        constructor() {
            // @ts-ignore
            super(0, 0, null); // Dummy super call
        }
        
        getMissingChunks() {
            const chunkSize = this.chunkSize;
            const beginChunk = Math.floor(this.start / chunkSize);
            const endChunk = Math.floor((this.end - 1) / chunkSize) + 1;
            const missingChunks = [];
            for (let chunk = beginChunk; chunk < endChunk; ++chunk) {
              if (!this._loadedChunks.has(chunk)) {
                missingChunks.push(chunk);
              }
            }
            return missingChunks;
        }

        get isDataLoaded() {
            if (this.numChunksLoaded === this.numChunks) {
                return true;
            }
            return this.getMissingChunks().length === 0;
        }
    }

    // We need to copy properties from `this` to `subStream`.
    // The original JS used prototype inheritance.
    // Here we can create a new instance and copy state.
    const subStream = new ChunkedStreamSubstream();
    // Copy state from parent
    subStream.bytes = this.bytes;
    subStream.chunkSize = this.chunkSize;
    subStream._loadedChunks = this._loadedChunks;
    subStream.numChunks = this.numChunks;
    subStream.manager = this.manager;
    subStream.progressiveDataLength = this.progressiveDataLength; // Shared? No, primitive. But updated via manager?
    // Actually, in JS `ChunkedStreamSubstream.prototype = Object.create(this)`
    // makes `this` the prototype. So `subStream` inherits `this` properties.
    // In TS/ES6 classes, this is not directly possible.
    // But `ChunkedStream` state is mostly static (bytes ref, manager ref).
    // `progressiveDataLength` is updated on `this`. If `subStream` inherits it via prototype, it sees updates.
    
    // To replicate prototype inheritance of an instance:
    Object.setPrototypeOf(subStream, this);
    
    subStream.pos = subStream.start = start;
    subStream.end = start + length || this.end;
    subStream.dict = dict;
    return subStream;
  }

  getBaseStreams() {
    return [this];
  }
}

export class ChunkedStreamManager {
  length: number;
  chunkSize: number;
  stream: ChunkedStream;
  pdfNetworkStream: any;
  disableAutoFetch: boolean;
  msgHandler: any;
  currRequestId: number;
  _chunksNeededByRequest: Map<number, Set<number>>;
  _requestsByChunk: Map<number, number[]>;
  _promisesByRequest: Map<number, any>;
  progressiveDataLength: number;
  aborted: boolean;
  _loadedStreamCapability: any;

  constructor(pdfNetworkStream: any, args: any) {
    this.length = args.length;
    this.chunkSize = args.rangeChunkSize;
    this.stream = new ChunkedStream(this.length, this.chunkSize, this);
    this.pdfNetworkStream = pdfNetworkStream;
    this.disableAutoFetch = args.disableAutoFetch;
    this.msgHandler = args.msgHandler;

    this.currRequestId = 0;

    this._chunksNeededByRequest = new Map();
    this._requestsByChunk = new Map();
    this._promisesByRequest = new Map();
    this.progressiveDataLength = 0;
    this.aborted = false;

    this._loadedStreamCapability = Promise.withResolvers();
  }

  sendRequest(begin: number, end: number) {
    const rangeReader = this.pdfNetworkStream.getRangeReader(begin, end);
    if (!rangeReader.isStreamingSupported) {
      rangeReader.onProgress = this.onProgress.bind(this);
    }

    let chunks: any[] | null = [],
      loaded = 0;
    return new Promise((resolve, reject) => {
      const readChunk = ({ value, done }: any) => {
        try {
          if (done) {
            const chunkData = arrayBuffersToBytes(chunks!);
            chunks = null;
            resolve(chunkData);
            return;
          }
          if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
            assert(
              value instanceof ArrayBuffer,
              "readChunk (sendRequest) - expected an ArrayBuffer."
            );
          }
          loaded += value.byteLength;

          if (rangeReader.isStreamingSupported) {
            this.onProgress({ loaded });
          }

          chunks!.push(value);
          rangeReader.read().then(readChunk, reject);
        } catch (e) {
          reject(e);
        }
      };
      rangeReader.read().then(readChunk, reject);
    }).then((data: any) => {
      if (this.aborted) {
        return; // Ignoring any data after abort.
      }
      this.onReceiveData({ chunk: data, begin });
    });
  }

  /**
   * Get all the chunks that are not yet loaded and group them into
   * contiguous ranges to load in as few requests as possible.
   */
  requestAllChunks(noFetch = false) {
    if (!noFetch) {
      const missingChunks = this.stream.getMissingChunks();
      this._requestChunks(missingChunks);
    }
    return this._loadedStreamCapability.promise;
  }

  _requestChunks(chunks: number[]) {
    const requestId = this.currRequestId++;

    const chunksNeeded = new Set<number>();
    this._chunksNeededByRequest.set(requestId, chunksNeeded);
    for (const chunk of chunks) {
      if (!this.stream.hasChunk(chunk)) {
        chunksNeeded.add(chunk);
      }
    }

    if (chunksNeeded.size === 0) {
      return Promise.resolve();
    }

    const capability = Promise.withResolvers();
    this._promisesByRequest.set(requestId, capability);

    const chunksToRequest = [];
    for (const chunk of chunksNeeded) {
      let requestIds = this._requestsByChunk.get(chunk);
      if (!requestIds) {
        requestIds = [];
        this._requestsByChunk.set(chunk, requestIds);

        chunksToRequest.push(chunk);
      }
      requestIds.push(requestId);
    }

    if (chunksToRequest.length > 0) {
      const groupedChunksToRequest = this.groupChunks(chunksToRequest);
      for (const groupedChunk of groupedChunksToRequest) {
        const begin = groupedChunk.beginChunk * this.chunkSize;
        const end = Math.min(
          groupedChunk.endChunk * this.chunkSize,
          this.length
        );
        this.sendRequest(begin, end).catch(capability.reject);
      }
    }

    return capability.promise.catch((reason: any) => {
      if (this.aborted) {
        return; // Ignoring any pending requests after abort.
      }
      throw reason;
    });
  }

  getStream() {
    return this.stream;
  }

  /**
   * Loads any chunks in the requested range that are not yet loaded.
   */
  requestRange(begin: number, end: number) {
    end = Math.min(end, this.length);

    const beginChunk = this.getBeginChunk(begin);
    const endChunk = this.getEndChunk(end);

    const chunks = [];
    for (let chunk = beginChunk; chunk < endChunk; ++chunk) {
      chunks.push(chunk);
    }
    return this._requestChunks(chunks);
  }

  requestRanges(ranges: any[] = []) {
    const chunksToRequest: any[] = [];
    for (const range of ranges) {
      const beginChunk = this.getBeginChunk(range.begin);
      const endChunk = this.getEndChunk(range.end);
      for (let chunk = beginChunk; chunk < endChunk; ++chunk) {
        if (!chunksToRequest.includes(chunk)) {
          chunksToRequest.push(chunk);
        }
      }
    }

    chunksToRequest.sort((a, b) => a - b);
    return this._requestChunks(chunksToRequest);
  }

  /**
   * Groups a sorted array of chunks into as few contiguous larger
   * chunks as possible.
   */
  groupChunks(chunks: number[]) {
    const groupedChunks = [];
    let beginChunk = -1;
    let prevChunk = -1;

    for (let i = 0, ii = chunks.length; i < ii; ++i) {
      const chunk = chunks[i];
      if (beginChunk < 0) {
        beginChunk = chunk;
      }

      if (prevChunk >= 0 && prevChunk + 1 !== chunk) {
        groupedChunks.push({ beginChunk, endChunk: prevChunk + 1 });
        beginChunk = chunk;
      }
      if (i + 1 === chunks.length) {
        groupedChunks.push({ beginChunk, endChunk: chunk + 1 });
      }

      prevChunk = chunk;
    }
    return groupedChunks;
  }

  onProgress(args: any) {
    this.msgHandler.send("DocProgress", {
      loaded: this.stream.numChunksLoaded * this.chunkSize + args.loaded,
      total: this.length,
    });
  }

  onReceiveData(args: any) {
    const chunk = args.chunk;
    const isProgressive = args.begin === undefined;
    const begin = isProgressive ? this.progressiveDataLength : args.begin;
    const end = begin + chunk.byteLength;

    const beginChunk = Math.floor(begin / this.chunkSize);
    const endChunk =
      end < this.length
        ? Math.floor(end / this.chunkSize)
        : Math.ceil(end / this.chunkSize);

    if (isProgressive) {
      this.stream.onReceiveProgressiveData(chunk);
      this.progressiveDataLength = end;
    } else {
      this.stream.onReceiveData(begin, chunk);
    }

    if (this.stream.isDataLoaded) {
      this._loadedStreamCapability.resolve(this.stream);
    }

    const loadedRequests = [];
    for (let curChunk = beginChunk; curChunk < endChunk; ++curChunk) {
      // The server might return more chunks than requested.
      const requestIds = this._requestsByChunk.get(curChunk);
      if (!requestIds) {
        continue;
      }
      this._requestsByChunk.delete(curChunk);

      for (const requestId of requestIds) {
        const chunksNeeded = this._chunksNeededByRequest.get(requestId);
        if (chunksNeeded?.has(curChunk)) {
          chunksNeeded.delete(curChunk);
        }

        if (chunksNeeded && chunksNeeded.size > 0) {
          continue;
        }
        loadedRequests.push(requestId);
      }
    }

    // If there are no pending requests, automatically fetch the next
    // unfetched chunk of the PDF file.
    if (!this.disableAutoFetch && this._requestsByChunk.size === 0) {
      let nextEmptyChunk;
      if (this.stream.numChunksLoaded === 1) {
        // This is a special optimization so that after fetching the first
        // chunk, rather than fetching the second chunk, we fetch the last
        // chunk.
        const lastChunk = this.stream.numChunks - 1;
        if (!this.stream.hasChunk(lastChunk)) {
          nextEmptyChunk = lastChunk;
        }
      } else {
        nextEmptyChunk = this.stream.nextEmptyChunk(endChunk);
      }
      if (Number.isInteger(nextEmptyChunk)) {
        this._requestChunks([nextEmptyChunk!]);
      }
    }

    for (const requestId of loadedRequests) {
      const capability = this._promisesByRequest.get(requestId);
      this._promisesByRequest.delete(requestId);
      capability.resolve();
    }

    this.msgHandler.send("DocProgress", {
      loaded: this.stream.numChunksLoaded * this.chunkSize,
      total: this.length,
    });
  }

  onError(err: any) {
    this._loadedStreamCapability.reject(err);
  }

  getBeginChunk(begin: number) {
    return Math.floor(begin / this.chunkSize);
  }

  getEndChunk(end: number) {
    return Math.floor((end - 1) / this.chunkSize) + 1;
  }

  abort(reason: any) {
    this.aborted = true;
    this.pdfNetworkStream?.cancelAllRequests(reason);

    for (const capability of this._promisesByRequest.values()) {
      capability.reject(reason);
    }
  }
}

