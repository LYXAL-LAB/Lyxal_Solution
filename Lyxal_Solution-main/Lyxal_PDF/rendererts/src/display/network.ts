
import { assert, stringToBytes, warn } from "../shared/util";
import {
  createHeaders,
  createResponseError,
  extractFilenameFromHeader,
  getResponseOrigin,
  validateRangeRequestCapabilities,
} from "./network_utils";

const OK_RESPONSE = 200;
const PARTIAL_CONTENT_RESPONSE = 206;

function getArrayBuffer(xhr: XMLHttpRequest): ArrayBuffer {
  const data = xhr.response;
  if (typeof data !== "string") {
    return data;
  }
  return stringToBytes(data).buffer as ArrayBuffer;
}

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

class NetworkManager {
  url: string;
  isHttp: boolean;
  headers: Map<string, string>;
  withCredentials: boolean;
  currXhrId: number;
  pendingRequests: Record<number, any>;
  _responseOrigin: string | null = null;

  constructor({ url, httpHeaders, withCredentials }: any) {
    this.url = url;
    this.isHttp = /^https?:/i.test(url);
    this.headers = createHeaders(this.isHttp, httpHeaders);
    this.withCredentials = withCredentials || false;

    this.currXhrId = 0;
    this.pendingRequests = Object.create(null);
  }

  request(args: any) {
    const xhr = new XMLHttpRequest();
    const xhrId = this.currXhrId++;
    const pendingRequest: any = (this.pendingRequests[xhrId] = { xhr });

    xhr.open("GET", this.url);
    xhr.withCredentials = this.withCredentials;
    for (const [key, val] of this.headers) {
      xhr.setRequestHeader(key, val);
    }
    if (this.isHttp && "begin" in args && "end" in args) {
      xhr.setRequestHeader("Range", `bytes=${args.begin}-${args.end - 1}`);
      pendingRequest.expectedStatus = PARTIAL_CONTENT_RESPONSE;
    } else {
      pendingRequest.expectedStatus = OK_RESPONSE;
    }
    xhr.responseType = "arraybuffer";

    assert(args.onError, "Expected `onError` callback to be provided.");
    xhr.onerror = () => {
      args.onError(xhr.status);
    };
    xhr.onreadystatechange = this.onStateChange.bind(this, xhrId);
    xhr.onprogress = this.onProgress.bind(this, xhrId);

    pendingRequest.onHeadersReceived = args.onHeadersReceived;
    pendingRequest.onDone = args.onDone;
    pendingRequest.onError = args.onError;
    pendingRequest.onProgress = args.onProgress;

    xhr.send(null);

    return xhrId;
  }

  onProgress(xhrId: number, evt: ProgressEvent) {
    const pendingRequest = this.pendingRequests[xhrId];
    if (!pendingRequest) {
      return; 
    }
    pendingRequest.onProgress?.(evt);
  }

  onStateChange(xhrId: number, evt: Event) {
    const pendingRequest = this.pendingRequests[xhrId];
    if (!pendingRequest) {
      return; 
    }

    const xhr = pendingRequest.xhr;
    if (xhr.readyState >= 2 && pendingRequest.onHeadersReceived) {
      pendingRequest.onHeadersReceived();
      delete pendingRequest.onHeadersReceived;
    }

    if (xhr.readyState !== 4) {
      return;
    }

    if (!(xhrId in this.pendingRequests)) {
      return;
    }

    delete this.pendingRequests[xhrId];

    if (xhr.status === 0 && this.isHttp) {
      pendingRequest.onError(xhr.status);
      return;
    }
    const xhrStatus = xhr.status || OK_RESPONSE;

    const ok_response_on_range_request =
      xhrStatus === OK_RESPONSE &&
      pendingRequest.expectedStatus === PARTIAL_CONTENT_RESPONSE;

    if (
      !ok_response_on_range_request &&
      xhrStatus !== pendingRequest.expectedStatus
    ) {
      pendingRequest.onError(xhr.status);
      return;
    }

    const chunk = getArrayBuffer(xhr);
    if (xhrStatus === PARTIAL_CONTENT_RESPONSE) {
      const rangeHeader = xhr.getResponseHeader("Content-Range");
      const matches = /bytes (\d+)-(\d+)\/(\d+)/.exec(rangeHeader || "");
      if (matches) {
        pendingRequest.onDone({
          begin: parseInt(matches[1], 10),
          chunk,
        });
      } else {
        warn(`Missing or invalid "Content-Range" header.`);
        pendingRequest.onError(0);
      }
    } else if (chunk) {
      pendingRequest.onDone({
        begin: 0,
        chunk,
      });
    } else {
      pendingRequest.onError(xhr.status);
    }
  }

  getRequestXhr(xhrId: number) {
    return this.pendingRequests[xhrId].xhr;
  }

  isPendingRequest(xhrId: number) {
    return xhrId in this.pendingRequests;
  }

  abortRequest(xhrId: number) {
    const xhr = this.pendingRequests[xhrId].xhr;
    delete this.pendingRequests[xhrId];
    xhr.abort();
  }
}

export class PDFNetworkStream {
  _source: any;
  _manager: NetworkManager;
  _rangeChunkSize: number;
  _fullRequestReader: PDFNetworkStreamFullRequestReader | null = null;
  _rangeRequestReaders: PDFNetworkStreamRangeRequestReader[] = [];

  constructor(source: any) {
    this._source = source;
    this._manager = new NetworkManager(source);
    this._rangeChunkSize = source.rangeChunkSize;
  }

  _onRangeRequestReaderClosed(reader: PDFNetworkStreamRangeRequestReader) {
    const i = this._rangeRequestReaders.indexOf(reader);
    if (i >= 0) {
      this._rangeRequestReaders.splice(i, 1);
    }
  }

  getFullReader() {
    assert(
      !this._fullRequestReader,
      "PDFNetworkStream.getFullReader can only be called once."
    );
    this._fullRequestReader = new PDFNetworkStreamFullRequestReader(
      this._manager,
      this._source
    );
    return this._fullRequestReader;
  }

  getRangeReader(begin: number, end: number) {
    const reader = new PDFNetworkStreamRangeRequestReader(
      this._manager,
      begin,
      end
    );
    reader.onClosed = this._onRangeRequestReaderClosed.bind(this);
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

class PDFNetworkStreamFullRequestReader {
  _manager: NetworkManager;
  _url: string;
  _fullRequestId: number;
  _headersCapability: any;
  _disableRange: boolean;
  _contentLength: number;
  _rangeChunkSize: number;
  _isStreamingSupported: boolean;
  _isRangeSupported: boolean;
  _cachedChunks: any[];
  _requests: any[];
  _done: boolean;
  _storedError: any;
  _filename: string | null;
  onProgress: any;

  constructor(manager: NetworkManager, source: any) {
    this._manager = manager;

    this._url = source.url;
    this._fullRequestId = manager.request({
      onHeadersReceived: this._onHeadersReceived.bind(this),
      onDone: this._onDone.bind(this),
      onError: this._onError.bind(this),
      onProgress: this._onProgress.bind(this),
    });
    this._headersCapability = withResolvers();
    this._disableRange = source.disableRange || false;
    this._contentLength = source.length;
    this._rangeChunkSize = source.rangeChunkSize;
    if (!this._rangeChunkSize && !this._disableRange) {
      this._disableRange = true;
    }

    this._isStreamingSupported = false;
    this._isRangeSupported = false;

    this._cachedChunks = [];
    this._requests = [];
    this._done = false;
    this._storedError = undefined;
    this._filename = null;

    this.onProgress = null;
  }

  _onHeadersReceived() {
    const fullRequestXhrId = this._fullRequestId;
    const fullRequestXhr = this._manager.getRequestXhr(fullRequestXhrId);

    this._manager._responseOrigin = getResponseOrigin(
      fullRequestXhr.responseURL
    );

    const rawResponseHeaders = fullRequestXhr.getAllResponseHeaders();
    const responseHeaders = new Headers(
      rawResponseHeaders
        ? rawResponseHeaders
            .trim()
            .replace(/[^\S ]+$/, "")
            .split(/[\r\n]+/)
            .map(x => {
              const parts = x.split(": ");
              const key = parts[0];
              const val = parts.slice(1).join(": ");
              return [key, val] as [string, string];
            })
        : []
    );

    const { allowRangeRequests, suggestedLength } =
      validateRangeRequestCapabilities({
        responseHeaders,
        isHttp: this._manager.isHttp,
        rangeChunkSize: this._rangeChunkSize,
        disableRange: this._disableRange,
      });

    if (allowRangeRequests) {
      this._isRangeSupported = true;
    }
    this._contentLength = suggestedLength || this._contentLength;

    this._filename = extractFilenameFromHeader(responseHeaders);

    if (this._isRangeSupported) {
      this._manager.abortRequest(fullRequestXhrId);
    }

    this._headersCapability.resolve();
  }

  _onDone(data: any) {
    if (data) {
      if (this._requests.length > 0) {
        const requestCapability = this._requests.shift();
        requestCapability.resolve({ value: data.chunk, done: false });
      } else {
        this._cachedChunks.push(data.chunk);
      }
    }
    this._done = true;
    if (this._cachedChunks.length > 0) {
      return;
    }
    for (const requestCapability of this._requests) {
      requestCapability.resolve({ value: undefined, done: true });
    }
    this._requests.length = 0;
  }

  _onError(status: number) {
    this._storedError = createResponseError(status, this._url);
    this._headersCapability.reject(this._storedError);
    for (const requestCapability of this._requests) {
      requestCapability.reject(this._storedError);
    }
    this._requests.length = 0;
    this._cachedChunks.length = 0;
  }

  _onProgress(evt: any) {
    this.onProgress?.({
      loaded: evt.loaded,
      total: evt.lengthComputable ? evt.total : this._contentLength,
    });
  }

  get filename() { return this._filename; }
  get isRangeSupported() { return this._isRangeSupported; }
  get isStreamingSupported() { return this._isStreamingSupported; }
  get contentLength() { return this._contentLength; }
  get headersReady() { return this._headersCapability.promise; }

  async read() {
    await this._headersCapability.promise;

    if (this._storedError) {
      throw this._storedError;
    }
    if (this._cachedChunks.length > 0) {
      const chunk = this._cachedChunks.shift();
      return { value: chunk, done: false };
    }
    if (this._done) {
      return { value: undefined, done: true };
    }
    const requestCapability = withResolvers();
    this._requests.push(requestCapability);
    return requestCapability.promise;
  }

  cancel(reason: any) {
    this._done = true;
    this._headersCapability.reject(reason);
    for (const requestCapability of this._requests) {
      requestCapability.resolve({ value: undefined, done: true });
    }
    this._requests.length = 0;
    if (this._manager.isPendingRequest(this._fullRequestId)) {
      this._manager.abortRequest(this._fullRequestId);
    }
    this._fullRequestReader = null;
  }
}

class PDFNetworkStreamRangeRequestReader {
  _manager: NetworkManager;
  _url: string;
  _requestId: number;
  _requests: any[];
  _queuedChunk: any;
  _done: boolean;
  _storedError: any;
  onProgress: any;
  onClosed: any;

  constructor(manager: NetworkManager, begin: number, end: number) {
    this._manager = manager;

    this._url = manager.url;
    this._requestId = manager.request({
      begin,
      end,
      onHeadersReceived: this._onHeadersReceived.bind(this),
      onDone: this._onDone.bind(this),
      onError: this._onError.bind(this),
      onProgress: this._onProgress.bind(this),
    });
    this._requests = [];
    this._queuedChunk = null;
    this._done = false;
    this._storedError = undefined;

    this.onProgress = null;
    this.onClosed = null;
  }

  _onHeadersReceived() {
    const responseOrigin = getResponseOrigin(
      this._manager.getRequestXhr(this._requestId)?.responseURL
    );

    if (responseOrigin !== this._manager._responseOrigin) {
      this._storedError = new Error(
        `Expected range response-origin "${responseOrigin}" to match "${this._manager._responseOrigin}".`
      );
      this._onError(0);
    }
  }

  _close() {
    this.onClosed?.(this);
  }

  _onDone(data: any) {
    const chunk = data.chunk;
    if (this._requests.length > 0) {
      const requestCapability = this._requests.shift();
      requestCapability.resolve({ value: chunk, done: false });
    } else {
      this._queuedChunk = chunk;
    }
    this._done = true;
    for (const requestCapability of this._requests) {
      requestCapability.resolve({ value: undefined, done: true });
    }
    this._requests.length = 0;
    this._close();
  }

  _onError(status: number) {
    this._storedError ??= createResponseError(status, this._url);
    for (const requestCapability of this._requests) {
      requestCapability.reject(this._storedError);
    }
    this._requests.length = 0;
    this._queuedChunk = null;
  }

  _onProgress(evt: any) {
    if (!this.isStreamingSupported) {
      this.onProgress?.({ loaded: evt.loaded });
    }
  }

  get isStreamingSupported() { return false; }

  async read() {
    if (this._storedError) {
      throw this._storedError;
    }
    if (this._queuedChunk !== null) {
      const chunk = this._queuedChunk;
      this._queuedChunk = null;
      return { value: chunk, done: false };
    }
    if (this._done) {
      return { value: undefined, done: true };
    }
    const requestCapability = withResolvers();
    this._requests.push(requestCapability);
    return requestCapability.promise;
  }

  cancel(reason: any) {
    this._done = true;
    for (const requestCapability of this._requests) {
      requestCapability.resolve({ value: undefined, done: true });
    }
    this._requests.length = 0;
    if (this._manager.isPendingRequest(this._requestId)) {
      this._manager.abortRequest(this._requestId);
    }
    this._close();
  }
}
