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
import { Stream } from "./stream";
import { Dict } from "./primitives";
import { unreachable } from "../shared/util";

// Lots of DecodeStreams are created whose buffers are never used.  For these
// we share a single empty buffer. This is (a) space-efficient and (b) avoids
// having special cases that would be required if we used |null| for an empty
// buffer.
const emptyBuffer = new Uint8Array(0);

// Super class for the decoding streams.
export abstract class DecodeStream extends BaseStream {
  _rawMinBufferLength: number;
  bufferLength: number;
  eof: boolean;
  buffer: Uint8Array;
  minBufferLength: number;

  constructor(maybeMinBufferLength: number = 0) {
    super();
    this._rawMinBufferLength = maybeMinBufferLength || 0;

    this.pos = 0;
    this.bufferLength = 0;
    this.eof = false;
    this.buffer = emptyBuffer;
    this.minBufferLength = 512;
    if (maybeMinBufferLength) {
      // Compute the first power of two that is as big as maybeMinBufferLength.
      while (this.minBufferLength < maybeMinBufferLength) {
        this.minBufferLength *= 2;
      }
    }
  }

  get isEmpty(): boolean {
    while (!this.eof && this.bufferLength === 0) {
      this.readBlock();
    }
    return this.bufferLength === 0;
  }

  ensureBuffer(requested: number): Uint8Array {
    const buffer = this.buffer;
    if (requested <= buffer.byteLength) {
      return buffer;
    }
    let size = this.minBufferLength;
    while (size < requested) {
      size *= 2;
    }
    const buffer2 = new Uint8Array(size);
    buffer2.set(buffer);
    return (this.buffer = buffer2);
  }

  getByte(): number {
    const pos = this.pos;
    while (this.bufferLength <= pos) {
      if (this.eof) {
        return -1;
      }
      this.readBlock();
    }
    return this.buffer[this.pos++];
  }

  getBytes(length?: number, decoderOptions: any = null): Uint8Array {
    const pos = this.pos;
    let end: number;

    if (length) {
      this.ensureBuffer(pos + length);
      end = pos + length;

      while (!this.eof && this.bufferLength < end) {
        this.readBlock(decoderOptions);
      }
      const bufEnd = this.bufferLength;
      if (end > bufEnd) {
        end = bufEnd;
      }
    } else {
      while (!this.eof) {
        this.readBlock(decoderOptions);
      }
      end = this.bufferLength;
    }

    this.pos = end;
    return this.buffer.subarray(pos, end);
  }

  // Abstract method in JS, needs implementation or abstract declaration in TS.
  // Since this class is used as a base, we mark it abstract but also provide a default throwing impl
  // because getByte calls it.
  readBlock(decoderOptions?: any): void {
     unreachable("Abstract method `readBlock` called");
  }

  async getImageData(length: number, decoderOptions: any): Promise<Uint8Array | null> {
    if (!this.canAsyncDecodeImageFromBuffer) {
      if (this.isAsyncDecoder) {
        return (this as any).decodeImage(null, decoderOptions);
      }
      return this.getBytes(length, decoderOptions);
    }
    const data = await this.stream!.asyncGetBytes();
    return (this as any).decodeImage(data, decoderOptions);
  }

  reset(): void {
    this.pos = 0;
  }

  makeSubStream(start: number, length: number, dict: Dict | null = null): Stream {
    if (length === undefined) {
      while (!this.eof) {
        this.readBlock();
      }
    } else {
      const end = start + length;
      while (this.bufferLength <= end && !this.eof) {
        this.readBlock();
      }
    }
    return new Stream(this.buffer, start, length, dict);
  }

  getBaseStreams(): BaseStream[] | null {
    return this.stream ? this.stream.getBaseStreams() : null;
  }

  clone(): Stream {
    // Make sure it has been fully read.
    while (!this.eof) {
      this.readBlock();
    }
    return new Stream(
      this.buffer,
      0,
      this.bufferLength,
      this.dict ? this.dict.clone() : null
    );
  }
}

export class StreamsSequenceStream extends DecodeStream {
  streams: BaseStream[];
  _onError: ((reason: any, objId: string) => void) | null;

  constructor(streams: BaseStream[], onError: ((reason: any, objId: string) => void) | null = null) {
    // We need to filter streams first, but super must be called first.
    // So we do a little trick or calculate length before super.
    const filteredStreams = streams.filter(s => s instanceof BaseStream);
    
    let maybeLength = 0;
    for (const stream of filteredStreams) {
      maybeLength +=
        stream instanceof DecodeStream
          ? stream._rawMinBufferLength
          : stream.length;
    }
    
    super(maybeLength);
    this.streams = filteredStreams;
    this._onError = onError;
  }

  readBlock(decoderOptions?: any): void {
    const streams = this.streams;
    if (streams.length === 0) {
      this.eof = true;
      return;
    }
    const stream = streams.shift()!;
    let chunk;
    try {
      chunk = stream.getBytes(undefined, decoderOptions);
    } catch (reason) {
      if (this._onError) {
        this._onError(reason, stream.dict?.objId);
        return;
      }
      throw reason;
    }
    const bufferLength = this.bufferLength;
    const newLength = bufferLength + chunk.length;
    const buffer = this.ensureBuffer(newLength);
    buffer.set(chunk, bufferLength);
    this.bufferLength = newLength;
  }

  getBaseStreams(): BaseStream[] | null {
    const baseStreamsBuf: BaseStream[] = [];
    for (const stream of this.streams) {
      const baseStreams = stream.getBaseStreams();
      if (baseStreams) {
        baseStreamsBuf.push(...baseStreams);
      }
    }
    return baseStreamsBuf.length > 0 ? baseStreamsBuf : null;
  }
}

