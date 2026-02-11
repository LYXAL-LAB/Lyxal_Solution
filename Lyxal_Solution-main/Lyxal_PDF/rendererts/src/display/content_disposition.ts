
/**
 * Extract filename from Content-Disposition header.
 */
export function getFilenameFromContentDispositionHeader(contentDisposition: string): string | null {
    let needsEncodingFixup = false;

    // Check if content disposition header is encoded.
    // This is not a standard format, but some servers do this.
    let filename: string | null = null;
    
    if (contentDisposition && contentDisposition.includes('%')) {
        try {
            contentDisposition = decodeURIComponent(contentDisposition);
            needsEncodingFixup = true;
        } catch (e) {
            // Ignore encoding errors
        }
    }

    // RFC 6266 parsing
    // filename*=utf-8''filename.pdf
    const filenameStarRegex = /filename\*=UTF-8''([\w%\-\.]+)(?:; ?|$)/i;
    const filenameRegex = /filename="([^"]*)"(?:; ?|$)/i;
    const filenameSimpleRegex = /filename=([^;]*)(?:; ?|$)/i;

    let match = filenameStarRegex.exec(contentDisposition);
    if (match) {
        filename = match[1];
        if (!needsEncodingFixup) {
             try {
                 filename = decodeURIComponent(filename);
             } catch(e) {}
        }
    } else {
        match = filenameRegex.exec(contentDisposition);
        if (match) {
            filename = match[1];
        } else {
            match = filenameSimpleRegex.exec(contentDisposition);
            if (match) {
                filename = match[1];
            }
        }
    }

    return filename ? filename.trim() : null;
}

