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

import { CmykICCBasedCS, IccColorSpace } from "./icc_colorspace.ts";
import {
  createValidAbsoluteUrl,
  FeatureTest,
  unreachable,
  warn,
} from "../shared/util.js";
import { ChunkedStreamManager } from "./chunked_stream.ts";
import { ImageResizer } from "./image_resizer.ts";
import { JpegStream } from "./jpeg_stream.ts";
import { JpxImage } from "./jpx.ts";
import { MissingDataException } from "./core_utils.ts";
import { OperatorList } from "./operator_list.ts";
import { PDFDocument } from "./document.ts";
import { Stream } from "./stream.ts";

declare const PDFJSDev: any;

function parseDocBaseUrl(url: string | null) {
  if (url) {
    const absoluteUrl = createValidAbsoluteUrl(url);
    if (absoluteUrl) {
      return absoluteUrl.href;
    }
    warn(`Invalid absolute docBaseUrl: "${url}".`);
  }
  return null;
}

class BasePdfManager {
  _docBaseUrl: string | null;
  _docId: string;
  _password: any;
  enableXfa: boolean;
  evaluatorOptions: any;
  pdfDocument: PDFDocument;

  constructor({
    // source,
    // disableAutoFetch,
    docBaseUrl,
    docId,
    enableXfa,
    evaluatorOptions,
    handler,
    // length,
    password,
    // rangeChunkSize,
  }: any) {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      this.constructor === BasePdfManager
    ) {
      unreachable("Cannot initialize BasePdfManager.");
    }
    this._docBaseUrl = parseDocBaseUrl(docBaseUrl);
    this._docId = docId;
    this._password = password;
    this.enableXfa = enableXfa;

    // Check `OffscreenCanvas` and `ImageDecoder` support once,
    // rather than repeatedly throughout the worker-thread code.
    evaluatorOptions.isOffscreenCanvasSupported &&=
      FeatureTest.isOffscreenCanvasSupported;
    evaluatorOptions.isImageDecoderSupported &&=
      FeatureTest.isImageDecoderSupported;
    this.evaluatorOptions = Object.freeze(evaluatorOptions);

    // Initialize image-options once per document.
    ImageResizer.setOptions(evaluatorOptions);
    JpegStream.setOptions(evaluatorOptions);
    OperatorList.setOptions(evaluatorOptions);

    const options = { ...evaluatorOptions, handler };
    JpxImage.setOptions(options);
    IccColorSpace.setOptions(options);
    CmykICCBasedCS.setOptions(options);
    
    // Initialized in subclasses
    this.pdfDocument = null as any; 
  }

  get docId() {
    return this._docId;
  }

  get password() {
    return this._password;
  }

  get docBaseUrl() {
    return this._docBaseUrl;
  }

  ensureDoc(prop: string, args?: any[]) {
    return this.ensure(this.pdfDocument, prop, args);
  }

  ensureXRef(prop: string, args?: any[]) {
    return this.ensure(this.pdfDocument.xref, prop, args);
  }

  ensureCatalog(prop: string, args?: any[]) {
    return this.ensure(this.pdfDocument.catalog, prop, args);
  }

  getPage(pageIndex: number) {
    return this.pdfDocument.getPage(pageIndex);
  }

  fontFallback(id: any, handler: any) {
    return this.pdfDocument.fontFallback(id, handler);
  }

  cleanup(manuallyTriggered = false) {
    return this.pdfDocument.cleanup(manuallyTriggered);
  }

  async ensure(obj: any, prop: string, args: any[] = []): Promise<any> {
    unreachable("Abstract method `ensure` called");
  }

  requestRange(begin: number, end: number) {
    unreachable("Abstract method `requestRange` called");
  }

  requestLoadedStream(noFetch = false) {
    unreachable("Abstract method `requestLoadedStream` called");
  }

  sendProgressiveData(chunk: any) {
    unreachable("Abstract method `sendProgressiveData` called");
  }

  updatePassword(password: any) {
    this._password = password;
  }

  terminate(reason: any) {
    unreachable("Abstract method `terminate` called");
  }
}

class LocalPdfManager extends BasePdfManager {
  _loadedStreamPromise: Promise<Stream>;

  constructor(args: any) {
    super(args);

    const stream = new Stream(args.source);
    this.pdfDocument = new PDFDocument(this, stream);
    this._loadedStreamPromise = Promise.resolve(stream);
  }

  async ensure(obj: any, prop: string, args: any[] = []) {
    const value = obj[prop];
    if (typeof value === "function") {
      return value.apply(obj, args);
    }
    return value;
  }

  requestRange(begin: number, end: number) {
    return Promise.resolve();
  }

  requestLoadedStream(noFetch = false) {
    return this._loadedStreamPromise;
  }

  terminate(reason: any) {}
}

class NetworkPdfManager extends BasePdfManager {
  streamManager: ChunkedStreamManager;

  constructor(args: any) {
    super(args);

    this.streamManager = new ChunkedStreamManager(args.source, {
      msgHandler: args.handler,
      length: args.length,
      disableAutoFetch: args.disableAutoFetch,
      rangeChunkSize: args.rangeChunkSize,
    });
    this.pdfDocument = new PDFDocument(this, this.streamManager.getStream());
  }

  async ensure(obj: any, prop: string, args: any[] = []): Promise<any> {
    try {
      const value = obj[prop];
      if (typeof value === "function") {
        return value.apply(obj, args);
      }
      return value;
    } catch (ex: any) {
      if (!(ex instanceof MissingDataException)) {
        throw ex;
      }
      await this.requestRange(ex.begin, ex.end);
      return this.ensure(obj, prop, args);
    }
  }

  requestRange(begin: number, end: number) {
    return this.streamManager.requestRange(begin, end);
  }

  requestLoadedStream(noFetch = false) {
    return this.streamManager.requestAllChunks(noFetch);
  }

  sendProgressiveData(chunk: any) {
    this.streamManager.onReceiveData({ chunk });
  }

  terminate(reason: any) {
    this.streamManager.abort(reason);
  }
}

export { LocalPdfManager, NetworkPdfManager };
