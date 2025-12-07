
/**
 * XML Helper for WebDAV/CalDAV Responses
 */

export class DavXmlResponse {

    static createMultiStatus(responses: string[]): string {
        return `<?xml version="1.0" encoding="utf-8" ?>
<d:multistatus xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/">
${responses.join('\n')}
</d:multistatus>`;
    }

    static createResponse(href: string, props: Record<string, any>, status: string = 'HTTP/1.1 200 OK'): string {
        const propString = Object.entries(props).map(([key, value]) => {
            if (value === undefined || value === null) return '';
            // Simple mapping for now
            return `<${key}>${value}</${key}>`;
        }).join('');

        return `<d:response>
 <d:href>${href}</d:href>
 <d:propstat>
  <d:prop>
   ${propString}
  </d:prop>
  <d:status>${status}</d:status>
 </d:propstat>
</d:response>`;
    }

    static createError(errorTag: string): string {
        return `<?xml version="1.0" encoding="utf-8" ?>
<d:error xmlns:d="DAV:">
  <d:${errorTag}/>
</d:error>`;
    }
}
