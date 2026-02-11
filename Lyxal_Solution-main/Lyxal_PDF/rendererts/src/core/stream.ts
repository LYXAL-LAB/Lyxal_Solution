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

import { BaseStream } from "./base_stream";
import { stringToBytes } from "../shared/util";
import { Dict } from "./primitives";

export class Stream extends BaseStream {
  bytes: Uint8Array;
  start: number;
  end: number;
  
  constructor(arrayBuffer: ArrayBufferLike | Uint8Array, start: number, length: number, dict: Dict | null) {
    super();

    this.bytes =
      arrayBuffer instanceof Uint8Array
        ? arrayBuffer
        : new Uint8Array(arrayBuffer);
    this.start = start || 0;
    this.pos = this.start;
    this.end = (start + length) || this.bytes.length;
    this.dict = dict;
  }

  get length(): number {
    return this.end - this.start;
  }

  get isEmpty(): boolean {
    return this.length === 0;
  }

  getByte(): number {
    if (this.pos >= this.end) {
      return -1;
    }
    return this.bytes[this.pos++];
  }

  getBytes(length?: number): Uint8Array {
    const bytes = this.bytes;
    const pos = this.pos;
    const strEnd = this.end;

    if (!length) {
      return bytes.subarray(pos, strEnd);
    }
    let end = pos + length;
    if (end > strEnd) {
      end = strEnd;
    }
    this.pos = end;
    return bytes.subarray(pos, end);
  }

  getByteRange(begin: number, end: number): Uint8Array {
    if (begin < 0) {
      begin = 0;
    }
    if (end > this.end) {
      end = this.end;
    }
    return this.bytes.subarray(begin, end);
  }

  reset(): void {
    this.pos = this.start;
  }

  moveStart(): void {
    this.start = this.pos;
  }

  makeSubStream(start: number, length?: number, dict: Dict | null = null): Stream {
    if (length === undefined) {
      length = this.end - start;
    }
    return new Stream(this.bytes.buffer, start, length, dict);
  }

  clone(): Stream {
    return new Stream(
      this.bytes.buffer,
      this.start,
      this.end - this.start,
      this.dict.clone()
    );
  }
}

export class StringStream extends Stream {
  constructor(str: string) {
    super(stringToBytes(str), 0, str.length, null);
  }
}

export class NullStream extends Stream {
  constructor() {
    super(new Uint8Array(0), 0, 0, null);
  }
}
