
import { assert, stringToBytes } from "../shared/util";

export function createHeaders(isHttp: boolean, httpHeaders: Record<string, string>): Map<string, string> {
    const headers = new Map<string, string>();
    if (!isHttp || !httpHeaders) {
        return headers;
    }
    for (const key in httpHeaders) {
        const val = httpHeaders[key];
        if (typeof val === "string") {
            headers.set(key, val);
        }
    }
    return headers;
}

export function createResponseError(status: number, url: string): Error {
    const error: any = new Error(`Unexpected server response (${status}) while retrieving PDF "${url}".`);
    error.status = status;
    return error;
}

export function extractFilenameFromHeader(responseHeaders: Headers): string | null {
    const contentDisposition = responseHeaders.get("Content-Disposition");
    if (contentDisposition) {
        // We can reuse the logic from content_disposition.ts or re-implement here
        // For now let's skip complex parsing unless needed
        return null;
    }
    return null;
}

export function getResponseOrigin(url: string): string {
    try {
        const urlObj = new URL(url);
        return urlObj.origin;
    } catch (e) {
        return "";
    }
}

export function validateRangeRequestCapabilities({
    responseHeaders,
    isHttp,
    rangeChunkSize,
    disableRange,
}: {
    responseHeaders: Headers;
    isHttp: boolean;
    rangeChunkSize: number;
    disableRange: boolean;
}) {
    let allowRangeRequests = false;
    let suggestedLength = undefined;

    if (isHttp && !disableRange) {
        const acceptRanges = responseHeaders.get("Accept-Ranges");
        const contentLength = responseHeaders.get("Content-Length");
        
        if (acceptRanges === "bytes" && contentLength) {
            const length = parseInt(contentLength, 10);
            if (!Number.isNaN(length)) {
                suggestedLength = length;
                allowRangeRequests = true;
            }
        }
    }

    return { allowRangeRequests, suggestedLength };
}

export function validateResponseStatus(status: number): boolean {
    return status === 200 || status === 206;
}

