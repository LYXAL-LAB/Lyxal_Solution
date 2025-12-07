import { CalDavBackend } from './backend';
import { DatabaseService } from './database';
import { AuthBackend } from './auth';
import { PrincipalBackend } from './principal';
import { DavXmlResponse } from './xml';
import { ICAL } from "@lyxal/ical";
import { CalendarAccess } from './types';

export class DavServer {
    private backend: CalDavBackend;
    private db: DatabaseService;
    private auth: AuthBackend;
    private principalBackend: PrincipalBackend;
    private port: number;

    constructor(port: number = 3000) {
        this.port = port;
        this.db = DatabaseService.getInstance();
        this.backend = new CalDavBackend();
        this.auth = new AuthBackend();
        this.principalBackend = new PrincipalBackend();
    }

    public start() {
        console.log(`[Lyxal_Dav] Starting server on port ${this.port}...`);

        Bun.serve({
            port: this.port,
            fetch: this.handleRequest.bind(this),
        });
    }

    /**
     * Resolves a CalDAV calendar-user-address (mailto:, urn:, or URL) to a local principal URI.
     */
    private resolveCalAddressToPrincipal(calAddress: string): string | null {
        if (!calAddress) return null;

        if (calAddress.startsWith('mailto:')) {
            const email = calAddress.substring(7);
            const [user, domain] = email.split('@');
            if (user) {
                // For MVP, we assume all users are local
                return `principals/users/${user}`;
            }
        }
        // Could add support for urn:uuid: or principal URLs here
        return null;
    }

    private async handleRequest(req: Request): Promise<Response> {
        const url = new URL(req.url);
        const method = req.method;

        console.log(`[${method}] ${url.pathname}`);

        try {
            // 1. Authenticate
            const principalUri = await this.auth.authenticate(req);

            if (!principalUri) {
                return new Response("Unauthorized", {
                    status: 401,
                    headers: { 'WWW-Authenticate': 'Basic realm="Lyxal_Dav"' }
                });
            }

            console.log(`[Auth] User authenticated as: ${principalUri}`);

            // 2. Route Request
            if (url.pathname.startsWith('/calendars/')) {
                return await this.handleCalendarRequest(req, principalUri);
            }

            if (url.pathname.startsWith('/principals/')) {
                return await this.handlePrincipalRequest(req, principalUri);
            }

            // Basic Root Response
            if (url.pathname === '/') {
                return new Response("Lyxal_Dav Server Running", { status: 200 });
            }

            return new Response("Not Found", { status: 404 });

        } catch (error) {
            console.error("Server Error:", error);
            return new Response("Internal Server Error", { status: 500 });
        }
    }

    private async handleCalendarRequest(req: Request, principalUri: string): Promise<Response> {
        const url = new URL(req.url);
        const method = req.method;
        const path = url.pathname;
        const parts = path.split('/').filter(p => p);

        if (parts.length < 2) {
            return new Response("Not Found", { status: 404 });
        }

        const requestedUser = parts[1];
        // In real world checking sharing permissions here
        if (!principalUri.endsWith(requestedUser)) {
            // pass
        }

        if (method === 'PROPFIND') {
            return await this.handlePropFind(req, principalUri, parts);
        }

        if (method === 'GET') {
            if (parts.length === 4) {
                const calendarName = parts[2];
                const objectName = parts[3];
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const calendar = calendars.find(c => c.uri === calendarName);

                if (!calendar) return new Response("Calendar Not Found", { status: 404 });

                const obj = await this.backend.getCalendarObject(calendar.id, objectName);
                if (!obj) return new Response("Object Not Found", { status: 404 });

                return new Response(obj.calendardata, {
                    status: 200,
                    headers: {
                        'Content-Type': 'text/calendar; charset=utf-8',
                        'ETag': `"${obj.etag}"`
                    }
                });
            }
        }

        if (method === 'PUT') {
            if (parts.length === 4) {
                const calendarName = parts[2];
                const objectName = parts[3];
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const calendar = calendars.find(c => c.uri === calendarName);

                if (!calendar) return new Response("Calendar Not Found", { status: 404 });

                const bodyText = await req.text();

                try {
                    const jcal = ICAL.parse(bodyText);
                    if (!jcal || jcal[0] !== 'vcalendar') {
                        return new Response("Invalid iCalendar data", { status: 400 });
                    }
                } catch (e) {
                    console.error("iCal Parse Error", e);
                    return new Response("Invalid iCalendar data", { status: 400 });
                }

                const etag = await this.backend.getCalendarObject(calendar.id, objectName)
                    ? await this.backend.updateCalendarObject(calendar.id, objectName, bodyText)
                    : await this.backend.createCalendarObject(calendar.id, objectName, bodyText);

                if (etag) {
                    return new Response(null, { headers: { 'ETag': `"${etag}"` }, status: 201 });
                }
                return new Response("Error processing PUT", { status: 500 });
            }
        }

        if (method === 'DELETE') {
            if (parts.length === 4) {
                const calendarName = parts[2];
                const objectName = parts[3];
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const calendar = calendars.find(c => c.uri === calendarName);

                if (!calendar) return new Response("Calendar Not Found", { status: 404 });

                await this.backend.deleteCalendarObject(calendar.id, objectName);
                return new Response(null, { status: 204 });
            }
        }

        if (method === 'REPORT') {
            if (parts.length === 3) {
                const calendarName = parts[2];
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const calendar = calendars.find(c => c.uri === calendarName);

                if (!calendar) return new Response("Calendar Not Found", { status: 404 });

                const bodyText = await req.text();
                const timeRangeRegex = /time-range[^>]+start="([^"]+)"[^>]+end="([^"]+)"/;
                const match = timeRangeRegex.exec(bodyText);

                let objects: any[] = [];

                if (match) {
                    try {
                        const startStr = match[1];
                        const endStr = match[2];
                        const start = ICAL.Time.fromString(startStr).toUnixTime();
                        const end = ICAL.Time.fromString(endStr).toUnixTime();

                        console.log(`[REPORT] Time-Range Query: ${startStr} (${start}) to ${endStr} (${end})`);
                        objects = await this.backend.getCalendarObjectsByTimeRange(calendar.id, start, end);
                    } catch (e) {
                        console.error("Error parsing time-range:", e);
                        objects = await this.backend.getCalendarObjects(calendar.id);
                    }
                } else {
                    objects = await this.backend.getCalendarObjects(calendar.id);
                }

                const responses = [];

                for (const obj of objects) {
                    const href = `/calendars/${parts[1]}/${calendarName}/${obj.uri}`;
                    responses.push(DavXmlResponse.createResponse(href, {
                        'd:resourcetype': '<d:collection/>',
                        'd:getetag': `"${obj.etag}"`,
                        'd:getcontenttype': 'text/calendar; charset=utf-8'
                    }));
                }

                const xml = DavXmlResponse.createMultiStatus(responses);
                return new Response(xml, { status: 207, headers: { 'Content-Type': 'application/xml' } });
            }
        }

        if (method === 'ACL') {
            if (parts.length === 3) {
                const calendarName = parts[2];
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const calendar = calendars.find(c => c.uri === calendarName);

                if (!calendar) return new Response("Calendar Not Found", { status: 404 });

                if (calendar.ownerPrincipal && calendar.ownerPrincipal !== principalUri) {
                    return new Response("Forbidden", { status: 403 });
                }

                const bodyText = await req.text();
                const aceRegex = /<[^:]*:ace>[\s\S]*?<[^:]*:href>([^<]+)<\/[^:]*:href>[\s\S]*?<[^:]*:grant>[\s\S]*?<[^:]*:([^/>]+)\/>[\s\S]*?<\/[^:]*:grant>[\s\S]*?<\/[^:]*:ace>/g;

                let match;
                const sharees = [];

                while ((match = aceRegex.exec(bodyText)) !== null) {
                    const href = match[1];
                    const privilege = match[2];

                    let accessLevel = CalendarAccess.READ;
                    if (privilege.toLowerCase().includes('write')) {
                        accessLevel = CalendarAccess.READWRITE;
                    }

                    sharees.push({ href, accessLevel, status: 1 });
                }

                if (sharees.length > 0) {
                    console.log(`[ACL] Updating shares for ${calendarName}`, sharees);
                    await this.backend.updateShare(calendar.id, sharees);
                }

                return new Response(null, { status: 200 });
            }
        }

        if (method === 'POST') {
            // Schedule Outbox (Free/Busy)
            if (parts.length === 2) {
                const calendarUser = parts[1];
                const bodyText = await req.text();

                if (bodyText.includes('VFREEBUSY')) {
                    try {
                        const jcal = ICAL.parse(bodyText);
                        const comp = new ICAL.Component(jcal);
                        const vfreebusy = comp.getFirstSubcomponent('vfreebusy');

                        if (vfreebusy) {
                            const dtstart = vfreebusy.getFirstPropertyValue('dtstart');
                            const dtend = vfreebusy.getFirstPropertyValue('dtend');

                            if (dtstart && dtend) {
                                const start = dtstart.toUnixTime();
                                const end = dtend.toUnixTime();

                                console.log(`[Scheduling] VFREEBUSY query for ${calendarUser} from ${start} to ${end}`);

                                const busyRanges = await this.backend.getFreeBusy(principalUri, start, end);

                                // Construct Reply
                                const reply = new ICAL.Component(['vcalendar', [], []]);
                                const replyFreeBusy = new ICAL.Component('vfreebusy');
                                replyFreeBusy.addPropertyWithValue('dtstart', dtstart);
                                replyFreeBusy.addPropertyWithValue('dtend', dtend);
                                replyFreeBusy.addPropertyWithValue('uid', vfreebusy.getFirstPropertyValue('uid') || 'lyxal-freebusy-reply');

                                for (const range of busyRanges) {
                                    const pStart = new ICAL.Time();
                                    pStart.fromUnixTime(range.start);

                                    const pEnd = new ICAL.Time();
                                    pEnd.fromUnixTime(range.end);

                                    const periodStr = `${pStart.toString()}/${pEnd.toString()}`;
                                    const prop = new ICAL.Property('freebusy');
                                    prop.setParameter('fbtype', 'BUSY');
                                    prop.setValue(periodStr);

                                    replyFreeBusy.addProperty(prop);
                                }

                                reply.addSubcomponent(replyFreeBusy);

                                return new Response(reply.toString(), {
                                    status: 200,
                                    headers: { 'Content-Type': 'text/calendar; charset=utf-8' }
                                });
                            }
                        }
                    } catch (e) {
                        console.error("FreeBusy Error", e);
                    }
                }

                // iTIP Scheduling (Invites/Replies/Cancels)
                if (bodyText.includes('METHOD:') && !bodyText.includes('VFREEBUSY')) {
                    try {
                        const jcal = ICAL.parse(bodyText);
                        const comp = new ICAL.Component(jcal);
                        const method = comp.getFirstPropertyValue('method')?.toUpperCase();

                        const vevent = comp.getFirstSubcomponent('vevent') || comp.getFirstSubcomponent('vtodo');
                        if (!vevent) {
                            return new Response("No event component found", { status: 400 });
                        }

                        console.log(`[Scheduling] Processing iTIP ${method} from ${principalUri}`);
                        let deliveredCount = 0;

                        if (method === 'REQUEST' || method === 'CANCEL') {
                            // REQUEST: Organizer sends invite to Attendees
                            // CANCEL: Organizer cancels, notify all Attendees
                            const attendees = vevent.getAllProperties('attendee');

                            for (const attendee of attendees) {
                                const calAddress = attendee.getFirstValue();
                                const targetPrincipalUri = this.resolveCalAddressToPrincipal(calAddress);

                                if (targetPrincipalUri && targetPrincipalUri !== principalUri) {
                                    console.log(`[Scheduling] Delivering ${method} to ${targetPrincipalUri}`);
                                    await this.backend.deliverToInbox(targetPrincipalUri, bodyText);
                                    deliveredCount++;
                                }
                            }
                        } else if (method === 'REPLY') {
                            // REPLY: Attendee responds, deliver to ORGANIZER
                            const organizer = vevent.getFirstPropertyValue('organizer');

                            if (organizer) {
                                const organizerPrincipalUri = this.resolveCalAddressToPrincipal(organizer);

                                if (organizerPrincipalUri && organizerPrincipalUri !== principalUri) {
                                    console.log(`[Scheduling] Delivering REPLY to Organizer ${organizerPrincipalUri}`);
                                    await this.backend.deliverToInbox(organizerPrincipalUri, bodyText);
                                    deliveredCount++;
                                }
                            } else {
                                console.warn("[Scheduling] REPLY received without ORGANIZER property.");
                            }
                        } else {
                            console.warn(`[Scheduling] Unhandled iTIP method: ${method}`);
                        }

                        console.log(`[Scheduling] Delivered to ${deliveredCount} recipients.`);
                        return new Response(null, { status: 200 });

                    } catch (e) {
                        console.error("iTIP Processing Error", e);
                        return new Response("iTIP Error", { status: 500 });
                    }
                }
            }
        }

        return new Response("Method Not Implemented", { status: 501 });
    }

    private async handlePropFind(req: Request, principalUri: string, parts: string[]): Promise<Response> {
        const depth = req.headers.get('Depth') || '0';

        if (parts.length === 2) {
            if (depth === '0') {
                const xml = DavXmlResponse.createMultiStatus([
                    DavXmlResponse.createResponse(req.url, {
                        'd:resourcetype': '<d:collection/>',
                        'd:displayname': 'Calendar Home'
                    })
                ]);
                return new Response(xml, { status: 207, headers: { 'Content-Type': 'application/xml' } });
            }

            if (depth === '1') {
                const calendars = await this.backend.getCalendarsForUser(principalUri);
                const responses = [];

                responses.push(DavXmlResponse.createResponse(req.url, {
                    'd:resourcetype': '<d:collection/>',
                    'd:displayname': 'Calendar Home'
                }));

                for (const cal of calendars) {
                    const href = `/calendars/${parts[1]}/${cal.uri}/`;
                    responses.push(DavXmlResponse.createResponse(href, {
                        'd:resourcetype': '<d:collection/><c:calendar/>',
                        'd:displayname': cal.displayname,
                        'c:supported-calendar-component-set': '<c:comp name="VEVENT"/><c:comp name="VTODO"/>',
                        'cs:getctag': cal.synctoken,
                        'd:sync-token': cal.synctoken
                    }));
                }

                const xml = DavXmlResponse.createMultiStatus(responses);
                return new Response(xml, { status: 207, headers: { 'Content-Type': 'application/xml' } });
            }
        }

        if (parts.length === 3) {
            const calendarName = parts[2];
            const calendars = await this.backend.getCalendarsForUser(principalUri);
            const calendar = calendars.find(c => c.uri === calendarName);

            if (!calendar) return new Response("Not Found", { status: 404 });

            const responses = [];

            responses.push(DavXmlResponse.createResponse(req.url, {
                'd:resourcetype': '<d:collection/><c:calendar/>',
                'd:displayname': calendar.displayname,
                'cs:getctag': calendar.synctoken
            }));

            if (depth === '1') {
                const objects = await this.backend.getCalendarObjects(calendar.id);
                for (const obj of objects) {
                    const href = `/calendars/${parts[1]}/${calendarName}/${obj.uri}`;
                    responses.push(DavXmlResponse.createResponse(href, {
                        'd:resourcetype': '<d:collection/>',
                        'd:getetag': `"${obj.etag}"`,
                        'd:getcontenttype': 'text/calendar; charset=utf-8',
                        'd:getcontentlength': obj.size
                    }));
                }
            }

            const xml = DavXmlResponse.createMultiStatus(responses);
            return new Response(xml, { status: 207, headers: { 'Content-Type': 'application/xml' } });
        }

        return new Response("Not Found", { status: 404 });
    }

    private async handlePrincipalRequest(req: Request, authPrincipalUri: string): Promise<Response> {
        const url = new URL(req.url);
        const method = req.method;

        // Path: /principals/users/username
        const path = url.pathname.replace(/^\//, ''); // remove leading slash

        if (method === 'PROPFIND') {
            const principal = await this.principalBackend.getPrincipalByPath(path);
            if (!principal) return new Response("Not Found", { status: 404 });

            // Construct XML
            const responses = [
                DavXmlResponse.createResponse(req.url, {
                    'd:resourcetype': '<d:principal/>',
                    'd:displayname': principal.displayname,
                    'd:principal-URL': `<d:href>/${principal.uri}</d:href>`,
                    'c:calendar-home-set': `<d:href>${principal['calendar-home-set']}</d:href>`,
                    'c:schedule-outbox-URL': `<d:href>${principal['schedule-outbox-URL']}</d:href>`,
                    'c:schedule-inbox-URL': `<d:href>${principal['schedule-inbox-URL']}</d:href>`,
                })
            ];

            const xml = DavXmlResponse.createMultiStatus(responses);
            return new Response(xml, { status: 207, headers: { 'Content-Type': 'application/xml' } });
        }

        return new Response("Method Not Allowed", { status: 405 });
    }
}
