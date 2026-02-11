
import { assert, warn } from "../shared/util";
import {
  createHeaders,
  createResponseError,
  extractFilenameFromHeader,
  getResponseOrigin,
  validateRangeRequestCapabilities,
  validateResponseStatus,
} from "./network_utils";

// Polyfill for Promise.withResolvers if needed
function withResolvers<T>() {
    let resolve!: (value: T | PromiseLike<T>) => void;
    let reject!: (reason?: any) => void;
    const promise = new Promise<T>((res, rej) => {
        resolve = res;
        reject = rej;
    });
    return { promise, resolve, reject };
}

function createFetchOptions(headers: any, withCredentials: boolean, abortController: AbortController) {
  return {
    method: "GET",
    headers,
    signal: abortController.signal,
    mode: "cors" as RequestMode,
    credentials: withCredentials ? "include" : "same-origin" as RequestCredentials,
    redirect: "follow" as RequestRedirect,
  };
}

function getArrayBuffer(val: any) {
  if (val instanceof Uint8Array) {
    return val.buffer;
  }
  if (val instanceof ArrayBuffer) {
    return val;
  }
  warn(`getArrayBuffer - unexpected data format: ${val}`);
  return new Uint8Array(val).buffer;
}

export class PDFFetchStream {
  source: any;
  isHttp: boolean;
  headers: Map<string, string>;
  _fullRequestReader: PDFFetchStreamReader | null = null;
  _rangeRequestReaders: PDFFetchStreamRangeReader[] = [];
  _responseOrigin: string | null = null;

  constructor(source: any) {
    this.source = source;
    this.isHttp = /^https?:/i.test(source.url);
    this.headers = createHeaders(this.isHttp, source.httpHeaders);
  }

  get _progressiveDataLength() {
    return this._fullRequestReader?._loaded ?? 0;
  }

  getFullReader() {
    assert(
      !this._fullRequestReader,
      "PDFFetchStream.getFullReader can only be called once."
    );
    this._fullRequestReader = new PDFFetchStreamReader(this);
    return this._fullRequestReader;
  }

  getRangeReader(begin: number, end: number) {
    if (end <= this._progressiveDataLength) {
      return null;
    }
    const reader = new PDFFetchStreamRangeReader(this, begin, end);
    this._rangeRequestReaders.push(reader);
    return reader;
  }

  cancelAllRequests(reason: any) {
    this._fullRequestReader?.cancel(reason);

    for (const reader of this._rangeRequestReaders.slice(0)) {
      reader.cancel(reason);
    }
  }
}

class PDFFetchStreamReader {
  _stream: PDFFetchStream;
  _reader: ReadableStreamDefaultReader | null = null;
  _loaded: number = 0;
  _filename: string | null = null;
  _withCredentials: boolean;
  _contentLength: number;
  _headersCapability: any;
  _disableRange: boolean;
  _rangeChunkSize: number;
  _abortController: AbortController;
  _isStreamingSupported: boolean;
  _isRangeSupported: boolean;
  onProgress: any = null;

  constructor(stream: PDFFetchStream) {
    this._stream = stream;
    
    const source = stream.source;
    this._withCredentials = source.withCredentials || false;
    this._contentLength = source.length;
    this._headersCapability = withResolvers();
    this._disableRange = source.disableRange || false;
    this._rangeChunkSize = source.rangeChunkSize;
    if (!this._rangeChunkSize && !this._disableRange) {
      this._disableRange = true;
    }

    this._abortController = new AbortController();
    this._isStreamingSupported = !source.disableStream;
    this._isRangeSupported = !source.disableRange;
    
    const headers = new Headers();
    stream.headers.forEach((value, key) => headers.append(key, value));

    const url = source.url;
    fetch(
      url,
      createFetchOptions(headers, this._withCredentials, this._abortController)
    )
      .then(response => {
        stream._responseOrigin = getResponseOrigin(response.url);

        if (!validateResponseStatus(response.status)) {
          throw createResponseError(response.status, url);
        }
        if (!response.body) throw new Error("Response body is null");
        
        this._reader = response.body.getReader();
        this._headersCapability.resolve();

        const responseHeaders = response.headers;

        const { allowRangeRequests, suggestedLength } =
          validateRangeRequestCapabilities({
            responseHeaders,
            isHttp: stream.isHttp,
            rangeChunkSize: this._rangeChunkSize,
            disableRange: this._disableRange,
          });

        this._isRangeSupported = allowRangeRequests;
        this._contentLength = suggestedLength || this._contentLength;

        this._filename = extractFilenameFromHeader(responseHeaders);

        if (!this._isStreamingSupported && this._isRangeSupported) {
          this.cancel(new Error("Streaming is disabled."));
        }
      })
      .catch(this._headersCapability.reject);
  }

  get headersReady() { return this._headersCapability.promise; }
  get filename() { return this._filename; }
  get contentLength() { return this._contentLength; }
  get isRangeSupported() { return this._isRangeSupported; }
  get isStreamingSupported() { return this._isStreamingSupported; }

  async read() {
    await this._headersCapability.promise;
    if (!this._reader) throw new Error("Reader not initialized");
    
    const { value, done } = await this._reader.read();
    if (done) {
      return { value, done };
    }
    this._loaded += value.byteLength;
    this.onProgress?.({
      loaded: this._loaded,
      total: this._contentLength,
    });

    return { value: getArrayBuffer(value), done: false };
  }

  cancel(reason: any) {
    this._reader?.cancel(reason);
    this._abortController.abort();
  }
}

class PDFFetchStreamRangeReader {
  _stream: PDFFetchStream;
  _reader: ReadableStreamDefaultReader | null = null;
  _loaded: number = 0;
  _withCredentials: boolean;
  _readCapability: any;
  _isStreamingSupported: boolean;
  _abortController: AbortController;
  onProgress: any = null;

  constructor(stream: PDFFetchStream, begin: number, end: number) {
    this._stream = stream;
    const source = stream.source;
    this._withCredentials = source.withCredentials || false;
    this._readCapability = withResolvers();
    this._isStreamingSupported = !source.disableStream;

    this._abortController = new AbortController();
    const headers = new Headers();
    stream.headers.forEach((value, key) => headers.append(key, value));
    headers.append("Range", `bytes=${begin}-${end - 1}`);

    const url = source.url;
    fetch(
      url,
      createFetchOptions(headers, this._withCredentials, this._abortController)
    )
      .then(response => {
        const responseOrigin = getResponseOrigin(response.url);

        if (responseOrigin !== stream._responseOrigin) {
          throw new Error(
            `Expected range response-origin "${responseOrigin}" to match "${stream._responseOrigin}".`
          );
        }
        if (!validateResponseStatus(response.status)) {
          throw createResponseError(response.status, url);
        }
        if (!response.body) throw new Error("Response body is null");
        
        this._readCapability.resolve();
        this._reader = response.body.getReader();
      })
      .catch(this._readCapability.reject);
  }

  get isStreamingSupported() {
    return this._isStreamingSupported;
  }

  async read() {
    await this._readCapability.promise;
    if (!this._reader) throw new Error("Reader not initialized");

    const { value, done } = await this._reader.read();
    if (done) {
      return { value, done };
    }
    this._loaded += value.byteLength;
    this.onProgress?.({ loaded: this._loaded });

    return { value: getArrayBuffer(value), done: false };
  }

  cancel(reason: any) {
    this._reader?.cancel(reason);
    this._abortController.abort();
  }
}
