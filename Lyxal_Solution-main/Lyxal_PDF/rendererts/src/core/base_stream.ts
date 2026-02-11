/* Copyright 2021 Mozilla Foundation
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

import { bytesToString, shadow, unreachable } from "../shared/util";

declare const PDFJSDev: any;

export abstract class BaseStream {
  pos: number = 0;
  stream: BaseStream | null = null;
  dict: any = null; // Dict type is likely needed here, but Dict depends on BaseStream via Stream probably. Circular.

  constructor() {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      new.target === BaseStream
    ) {
      unreachable("Cannot initialize BaseStream.");
    }
  }

  // eslint-disable-next-line getter-return
  get length(): number {
    return unreachable("Abstract getter `length` accessed");
  }

  // eslint-disable-next-line getter-return
  get isEmpty(): boolean {
    return unreachable("Abstract getter `isEmpty` accessed");
  }

  get isDataLoaded(): boolean {
    return shadow(this, "isDataLoaded", true);
  }

  getByte(): number {
    return unreachable("Abstract method `getByte` called");
  }

  getBytes(length?: number, decoderOptions?: any): Uint8Array {
    return unreachable("Abstract method `getBytes` called");
  }

  /**
   * NOTE: This method can only be used to get image-data that is guaranteed
   *       to be fully loaded, since otherwise intermittent errors may occur;
   *       note the `ObjectLoader` class.
   */
  async getImageData(length: number, decoderOptions?: any): Promise<Uint8Array | null> {
    return this.getBytes(length, decoderOptions);
  }

  async asyncGetBytes(): Promise<Uint8Array | null> {
    return unreachable("Abstract method `asyncGetBytes` called");
  }

  get isAsync(): boolean {
    return false;
  }

  get isAsyncDecoder(): boolean {
    return false;
  }

  get canAsyncDecodeImageFromBuffer(): boolean {
    return false;
  }

  async getTransferableImage(): Promise<any> {
    return null;
  }

  peekByte(): number {
    const peekedByte = this.getByte();
    if (peekedByte !== -1) {
      this.pos--;
    }
    return peekedByte;
  }

  peekBytes(length: number): Uint8Array {
    const bytes = this.getBytes(length);
    this.pos -= bytes.length;
    return bytes;
  }

  getUint16(): number {
    const b0 = this.getByte();
    const b1 = this.getByte();
    if (b0 === -1 || b1 === -1) {
      return -1;
    }
    return (b0 << 8) + b1;
  }

  getInt32(): number {
    const b0 = this.getByte();
    const b1 = this.getByte();
    const b2 = this.getByte();
    const b3 = this.getByte();
    return (b0 << 24) + (b1 << 16) + (b2 << 8) + b3;
  }

  getByteRange(begin: number, end: number): Uint8Array {
    return unreachable("Abstract method `getByteRange` called");
  }

  getString(length?: number): string {
    return bytesToString(this.getBytes(length as number));
  }

  skip(n?: number): void {
    this.pos += n || 1;
  }

  reset(): void {
    unreachable("Abstract method `reset` called");
  }

  moveStart(): void {
    unreachable("Abstract method `moveStart` called");
  }

  makeSubStream(start: number, length: number, dict: any = null): BaseStream {
    return unreachable("Abstract method `makeSubStream` called");
  }

  /**
   * @returns {Array | null}
   */
  getBaseStreams(): BaseStream[] | null {
    return null;
  }

  getOriginalStream(): BaseStream {
    return this.stream?.getOriginalStream() || this;
  }
}

