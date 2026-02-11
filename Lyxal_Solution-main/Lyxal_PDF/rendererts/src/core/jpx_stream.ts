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

import { shadow, unreachable } from "../shared/util";
import { BaseStream } from "./base_stream";
import { DecodeStream } from "./decode_stream";
import { Dict } from "./primitives";
import { JpxImage } from "./jpx";

/**
 * For JPEG 2000's we use a library to decode these images and
 * the stream behaves like all the other DecodeStreams.
 */
export class JpxStream extends DecodeStream {
  stream: BaseStream;
  dict: Dict | null;
  maybeLength: number | null;
  params: Dict | null;
  _bytes: Uint8Array | null = null;

  constructor(
    stream: BaseStream,
    maybeLength: number | null,
    params: Dict | null
  ) {
    super(maybeLength ?? undefined);

    this.stream = stream;
    this.dict = stream.dict;
    this.maybeLength = maybeLength;
    this.params = params;
  }

  get bytes(): Uint8Array {
    // If `this.maybeLength` is null, we'll get the entire stream.
    if (this._bytes === null) {
      this._bytes = this.stream.getBytes(this.maybeLength ?? undefined);
    }
    return shadow(this, "bytes", this._bytes!);
  }

  ensureBuffer(requested: number): Uint8Array {
    // No-op, since `this.readBlock` will always parse the entire image and
    // directly insert all of its data into `this.buffer`.
    return this.buffer;
  }

  readBlock(decoderOptions?: any): void {
    unreachable("JpxStream.readBlock");
  }

  get isAsyncDecoder(): boolean {
    return true;
  }

  async decodeImage(bytes: Uint8Array | null, decoderOptions?: any): Promise<Uint8Array> {
    if (this.eof) {
      return this.buffer;
    }
    bytes ||= this.bytes;
    this.buffer = await JpxImage.decode(bytes!, decoderOptions);
    this.bufferLength = this.buffer.length;
    this.eof = true;

    return this.buffer;
  }

  get canAsyncDecodeImageFromBuffer(): boolean {
    return this.stream.isAsync;
  }
}

