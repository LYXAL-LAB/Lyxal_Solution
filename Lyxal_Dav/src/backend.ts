import { DatabaseService } from './database';
import {
    CalendarInfo,
    CalendarObject,
    CalendarChange,
    SchedulingObject,
    SubscriptionInfo,
    CalendarAccess,
    CalendarType
} from './types';
import { getSurrealClient } from "@lyxal/surreal";
import { ICAL } from "@lyxal/ical";

/**
 * CalDavBackend
 * 
 * TypeScript implementation of Nextcloud's CalDavBackend.php
 * Handles interaction with Lyxal_Calendar SurrealDB.
 */
export class CalDavBackend {
    private db: DatabaseService;

    constructor() {
        this.db = DatabaseService.getInstance();
    }

    /**
     * Extracts the first and last occurrence from an iCalendar string.
     * Returns unix timestamps.
     */
    private getDenormalizedData(calendarData: string): { first: number, last: number } {
        try {
            const jcal = ICAL.parse(calendarData);
            const comp = new ICAL.Component(jcal);
            const vevent = comp.getFirstSubcomponent('vevent');

            if (!vevent) {
                return { first: 0, last: 0 };
            }

            // Basic extraction (Expand for recurrence later if needed)
            const dtstart = vevent.getFirstPropertyValue('dtstart');
            const dtend = vevent.getFirstPropertyValue('dtend') || vevent.getFirstPropertyValue('duration');

            // Simple conversion to unix timestamp
            const first = dtstart ? dtstart.toUnixTime() : 0;
            let last = first;

            if (dtend) {
                if (dtend instanceof ICAL.Time) {
                    last = dtend.toUnixTime();
                } else if (dtend instanceof ICAL.Duration) {
                    // If it's a duration, add to start
                    // This part needs proper handling via ICAL library if duration is complex
                    // For MVP we assume end time exists or duration is simple
                    last = first + dtend.toSeconds();
                }
            }

            return { first, last };
        } catch (e) {
            console.error("Error extracting dates:", e);
            return { first: 0, last: 0 };
        }
    }

    /**
     * Returns a list of calendars for a principal.
     * @param principalUri
     */
    async getCalendarsForUser(principalUri: string): Promise<CalendarInfo[]> {
        const client = this.db.getClient();
        try {
            // We use the raw query for now to ensure mapping correctness until functions are fully deployed
            // We use a UNION-like approach: fetch owned + fetch shared
            // 1. Owned calendars
            const ownedQuery = `
                SELECT 
                    id, 
                    identity.name as uri, 
                    identity.displayname as displayname,
                    identity.description as description,
                    content.calendarcolor as calendarcolor,
                    content.timezone as timezone,
                    content.components as components,
                    metadata.synctoken as synctoken,
                    metadata.owner as principaluri,
                    content.transparent as transparent,
                    false as readonly
                FROM calendars 
                WHERE metadata.owner = $principalUri
                ORDER BY content.calendarorder ASC;
            `;

            // 2. Shared calendars
            // We join davshares to get rights
            const sharedQuery = `
                SELECT 
                    resource.id as id,
                    resource.identity.name as uri,
                    resource.identity.displayname as displayname,
                    resource.identity.description as description,
                    resource.content.calendarcolor as calendarcolor,
                    resource.content.timezone as timezone,
                    resource.content.components as components,
                    resource.metadata.synctoken as synctoken,
                    resource.metadata.owner as principaluri, -- Owner is the original owner
                    resource.content.transparent as transparent,
                    true as is_shared,
                    content.access_level.identity.code as access_code
                FROM davshares
                WHERE principaluri = $principalUri;
            `;

            const [ownedResult, sharedResult] = await Promise.all([
                client.query<CalendarInfo[][]>(ownedQuery, { principalUri }),
                client.query<any[][]>(sharedQuery, { principalUri })
            ]);

            const owned = (ownedResult[0] && Array.isArray(ownedResult[0])) ? ownedResult[0] : [];

            // Process shared
            // If access_code is 'READ', then readonly=true
            // IF access_code is 'WRITE' or 'READWRITE', then readonly=false (but it is still shared)
            const sharedRaw = (sharedResult[0] && Array.isArray(sharedResult[0])) ? sharedResult[0] : [];

            const sharedMapped: CalendarInfo[] = sharedRaw.map((row: any) => {
                const isReadOnly = (row.access_code === 'READ');

                return {
                    id: row.id,
                    uri: row.uri, // Note: Shared calendars might need a different URI convention in full implementation (e.g. shared-row.uri) logic, but for now we reuse name
                    principaluri: row.principaluri,
                    synctoken: row.synctoken || 0,
                    displayname: row.displayname + ' (Shared)', // UI hint
                    description: row.description,
                    calendarcolor: row.calendarcolor,
                    timezone: row.timezone,
                    components: row.components ? row.components.split(',') : ['VEVENT', 'VTODO'],
                    transparent: row.transparent || false,
                    readonly: isReadOnly,
                    ownerPrincipal: row.principaluri // The original owner
                };
            });

            return [...owned.map((row: any) => ({
                id: row.id,
                uri: row.uri,
                principaluri: row.principaluri,
                synctoken: row.synctoken || 0,
                displayname: row.displayname,
                description: row.description,
                calendarcolor: row.calendarcolor,
                timezone: row.timezone,
                components: row.components ? row.components.split(',') : ['VEVENT', 'VTODO'],
                transparent: row.transparent || false,
                readonly: false,
                ownerPrincipal: row.principaluri
            })), ...sharedMapped];

        } catch (error) {
            console.error("Error fetching calendars for user:", error);
            throw error;
        }
    }

    /**
     * Creates a new calendar for a principal.
     * @param principalUri
     * @param calendarUri
     * @param properties
     */
    async createCalendar(principalUri: string, calendarUri: string, properties: any): Promise<void> {
        const client = this.db.getClient();

        // Map CalDAV properties to SurrealDB fields
        // See CalDavBackend.php propertyMap
        const displayName = properties['{DAV:}displayname'] || null;
        const description = properties['{urn:ietf:params:xml:ns:caldav}calendar-description'] || null;
        const calendarOrder = properties['{http://apple.com/ns/ical/}calendar-order'] || 0;
        const calendarColor = properties['{http://apple.com/ns/ical/}calendar-color'] || null;
        const timezone = properties['{urn:ietf:params:xml:ns:caldav}calendar-timezone'] || null;
        const transparent = properties['{urn:ietf:params:xml:ns:caldav}schedule-calendar-transp']?.value === 'transparent';

        const components = properties['{urn:ietf:params:xml:ns:caldav}supported-calendar-component-set']
            ? properties['{urn:ietf:params:xml:ns:caldav}supported-calendar-component-set'].value.join(',')
            : null;

        try {
            // Using SurrealDB 'CREATE' to insert a new record into 'calendars' table
            // We use the calendarUri as the ID or SLUG
            const query = `
                CREATE calendars CONTENT {
                    identity: {
                        name: $calendarUri,
                        slug: $calendarUri,
                        displayname: $displayName,
                        description: $description
                    },
                    content: {
                        calendarcolor: $calendarColor,
                        calendarorder: $calendarOrder,
                        timezone: $timezone,
                        components: $components,
                        transparent: $transparent
                    },
                    metadata: {
                        owner: $principalUri,
                        synctoken: 1,
                        created_at: time::now(),
                        lastmodified: time::now()
                    }
                };
            `;

            await client.query(query, {
                calendarUri,
                displayName,
                description,
                calendarOrder,
                calendarColor,
                timezone,
                components,
                transparent,
                principalUri
            });

            console.log(`[Lyxal_Dav] Created calendar '${calendarUri}' for ${principalUri}`);

        } catch (error) {
            console.error(`Error creating calendar ${calendarUri}:`, error);
            throw error;
        }
    }

    /**
     * Delete a calendar and all it's objects
     * @param calendarId
     */
    async deleteCalendar(calendarId: string): Promise<void> {
        const client = this.db.getClient();
        try {
            // Delete the calendar (and cascading objects ideally, but for safety we delete explicitely)
            // SurrealDB cascade delete is not fully standard yet, so we delete objects first.
            await client.query('DELETE calendarobjects WHERE calendarid = $calendarId', { calendarId });
            await client.query('DELETE calendars WHERE id = $calendarId', { calendarId });
            console.log(`[Lyxal_Dav] Deleted calendar ${calendarId}`);
        } catch (error) {
            console.error(`Error deleting calendar ${calendarId}:`, error);
            throw error;
        }
    }

    /**
     * Returns all calendar objects for a calendar.
     * @param calendarId
     */
    async getCalendarObjects(calendarId: string): Promise<CalendarObject[]> {
        const client = this.db.getClient();
        try {
            // We cast the result to CalendarObject[]
            const query = `SELECT * FROM calendarobjects WHERE calendarid = $calendarId`;
            const [result] = await client.query<CalendarObject[][]>(query, { calendarId });
            return (result as any[]) || [];
        } catch (error) {
            console.error(`Error fetching objects for calendar ${calendarId}:`, error);
            throw error;
        }
    }

    /**
     * Returns a specific calendar object.
     * @param calendarId
     * @param objectUri
     */
    async getCalendarObject(calendarId: string, objectUri: string): Promise<CalendarObject | null> {
        const client = this.db.getClient();
        try {
            const query = `
                SELECT * FROM calendarobjects 
                WHERE calendarid = $calendarId 
                AND uri = $objectUri 
                LIMIT 1;
            `;
            const [result] = await client.query<CalendarObject[][]>(query, { calendarId, objectUri });
            return result && result[0] ? (result[0] as unknown as CalendarObject) : null;
        } catch (error) {
            console.error(`Error fetching object ${objectUri}:`, error);
            throw error;
        }
    }

    /**
     * Creates a new calendar object.
     * @param calendarId
     * @param objectUri
     * @param calendarData
     */
    async createCalendarObject(calendarId: string, objectUri: string, calendarData: string): Promise<string | null> {
        const client = this.db.getClient();
        try {
            const { first, last } = this.getDenormalizedData(calendarData);

            const query = `
                CREATE calendarobjects CONTENT {
                    calendarid: $calendarId,
                    uri: $objectUri,
                    calendardata: $calendarData,
                    lastmodified: time::now().to_unix(),
                    etag: rand::uuid(),
                    size: string::len($calendarData),
                    firstoccurence: $first,
                    lastoccurence: $last
                };
            `;

            const [result] = await client.query<any[][]>(query, { calendarId, objectUri, calendarData, first, last });

            await this.updateCalendarSyncToken(calendarId);

            return result && result[0] ? result[0].etag : null;
        } catch (error) {
            console.error(`Error creating object ${objectUri}:`, error);
            throw error;
        }
    }

    /**
     * Updates an existing calendar object.
     * @param calendarId
     * @param objectUri
     * @param calendarData
     */
    async updateCalendarObject(calendarId: string, objectUri: string, calendarData: string): Promise<string | null> {
        const client = this.db.getClient();
        try {
            const { first, last } = this.getDenormalizedData(calendarData);

            const query = `
                UPDATE calendarobjects SET 
                    calendardata = $calendarData,
                    lastmodified: time::now().to_unix(),
                    etag = rand::uuid(),
                    size = string::len($calendarData),
                    firstoccurence: $first,
                    lastoccurence: $last
                WHERE calendarid = $calendarId AND uri = $objectUri;
             `;

            const [result] = await client.query<any[][]>(query, { calendarId, objectUri, calendarData, first, last });

            await this.updateCalendarSyncToken(calendarId);

            return result && result[0] ? result[0].etag : null;
        } catch (error) {
            console.error(`Error updating object ${objectUri}:`, error);
            throw error;
        }
    }

    /**
     * Deletes an existing calendar object.
     * @param calendarId
     * @param objectUri
     */
    async deleteCalendarObject(calendarId: string, objectUri: string): Promise<void> {
        const client = this.db.getClient();
        try {
            const query = `DELETE calendarobjects WHERE calendarid = $calendarId AND uri = $objectUri;`;
            await client.query(query, { calendarId, objectUri });
            await this.updateCalendarSyncToken(calendarId);
        } catch (error) {
            console.error(`Error deleting object ${objectUri}:`, error);
            throw error;
        }
    }

    /**
     * Helper to update the sync token of a calendar after changes
     */
    private async updateCalendarSyncToken(calendarId: string): Promise<void> {
        const client = this.db.getClient();
        const query = `UPDATE calendars SET metadata.synctoken = metadata.synctoken + 1 WHERE id = $calendarId;`;
        await client.query(query, { calendarId });
    }

    /**
     * The sync-token is a timestamp.
     * @param calendarId
     * @param syncToken
     * @param syncLevel
     * @param limit
     */
    async getChangesForCalendar(calendarId: string, syncToken: number, syncLevel: number, limit?: number): Promise<{
        syncToken: number;
        added: string[];
        modified: string[];
        deleted: string[];
    }> {
        const client = this.db.getClient();

        // 1. Get current sync token of the calendar
        const [calendarResult] = await client.query<any[][]>(`SELECT metadata.synctoken as token FROM calendars WHERE id = $calendarId`, { calendarId });
        const currentToken = calendarResult && calendarResult[0] ? calendarResult[0].token : 0;

        // 2. Fetch changes
        const query = `
            SELECT uri, operation, synctoken 
            FROM calendarchanges 
            WHERE calendarid = $calendarId 
            AND synctoken > $syncToken
            ORDER BY synctoken ASC;
        `;

        const [changesResult] = await client.query<any[][]>(query, { calendarId, syncToken });
        const changes = (changesResult as any[]) || [];

        const result = {
            syncToken: currentToken,
            added: [] as string[],
            modified: [] as string[],
            deleted: [] as string[]
        };

        // 3. Bucket changes
        for (const change of changes) {
            switch (change.operation) {
                case 1: // Add
                    result.added.push(change.uri);
                    break;
                case 2: // Modify
                    result.modified.push(change.uri);
                    break;
                case 3: // Delete
                    result.deleted.push(change.uri);
                    break;
            }
        }

        return result;
    }
    /**
     * Returns calendar objects within a time range.
     * @param calendarId 
     * @param start Unix timestamp
     * @param end Unix timestamp
     */
    async getCalendarObjectsByTimeRange(calendarId: string, start: number, end: number): Promise<CalendarObject[]> {
        const client = this.db.getClient();
        try {
            // Logic: Object overlaps if (firstOccurence <= end) AND (lastOccurence >= start)
            const query = `
                SELECT * FROM calendarobjects 
                WHERE calendarid = $calendarId 
                AND firstoccurence <= $end 
                AND lastoccurence >= $start;
            `;
            const [result] = await client.query<CalendarObject[][]>(query, { calendarId, start, end });
            return (result as any[]) || [];
        } catch (error) {
            console.error(`Error fetching objects by time range for calendar ${calendarId}:`, error);
            throw error;
        }
    }

    /**
     * Updates the shares for a calendar.
     * This implementation replaces the share list for a given calendar (simplification).
     * @param calendarId 
     * @param sharees List of sharees to set
     */
    async updateShare(calendarId: string, sharees: any[]): Promise<void> {
        const client = this.db.getClient();
        try {
            // 1. Remove existing shares for this calendar
            await client.query(`DELETE davshares WHERE resource = $calendarId`, { calendarId });

            // 2. Insert new shares
            for (const sharee of sharees) {
                // Map numeric access to code
                let accessCode = 'READ';
                if (sharee.accessLevel === CalendarAccess.READWRITE || sharee.accessLevel === CalendarAccess.ADMIN) {
                    accessCode = 'WRITE';
                }

                const query = `
                    CREATE davshares CONTENT {
                        resource: $calendarId,
                        principaluri: $href,
                        content: {
                            share_type: share_types:user, -- Default to user share
                            access_level: (SELECT id FROM access_levels WHERE identity.code = $accessCode LIMIT 1)
                        },
                        identity: {
                            publicuri: rand::uuid() -- Auto generate a public link token just in case
                        }
                    };
                `;

                await client.query(query, {
                    calendarId,
                    href: sharee.href,
                    accessCode
                });
            }

            // Update sync token of the calendar so clients know something changed (properties)
            await this.updateCalendarSyncToken(calendarId);

        } catch (error) {
            console.error(`Error updating shares for calendar ${calendarId}:`, error);
            throw error;
        }
    }

    /**
     * Retrieves Free/Busy information for a user within a time range.
     * @param principalUri 
     * @param start Unix timestamp
     * @param end Unix timestamp
     */
    async getFreeBusy(principalUri: string, start: number, end: number): Promise<any[]> {
        const client = this.db.getClient();
        try {
            // 1. Get all calendars for this user (including shared ones that affect availability)
            // For MVP: We only look at OWNED calendars that are TRANSPARENT=FALSE (Opaque)
            // Access permissions check is implicit: we are doing this ON BEHALF of the system/user query

            const calendars = await this.getCalendarsForUser(principalUri);

            // Filter: Only Opaque calendars contribute to Busy time
            // And usually only "VEVENT" components
            // In a real system we check transparency on the Calendar AND the Event
            const relevantCalendars = calendars.filter(c => !c.transparent);
            const calendarIds = relevantCalendars.map(c => c.id);

            if (calendarIds.length === 0) {
                return [];
            }

            // 2. Query objects in these calendars overlapping the range
            // We use the same logic as getCalendarObjectsByTimeRange but for multiple calendars
            // Since we can't easily pass array of IDs in simple query builder without complex WHERE OR
            // We'll iterate (optimized approach would be a single IN query)

            let allObjects: CalendarObject[] = [];

            // TODO: Optimize with WHERE calendarid IN [...]
            const promises = calendarIds.map(cid => this.getCalendarObjectsByTimeRange(cid, start, end));
            const results = await Promise.all(promises);

            results.forEach(objs => allObjects.push(...objs));

            // 3. Extract Busy Ranges
            // We assume all objects returned are BUSY (Opaque) because we filtered calendars
            // In full implementation, we must parse the VEVENT to check individual TRANSP prop.

            const freeBusyRanges = allObjects.map(obj => {
                // Return simple objects
                // In reality, we might need to parse recurrence here if we didn't expand fully in DB
                // But since we denormalized first/last, we treat the whole span as busy for the MVP
                // This is "Good Enough" for simple blocking, but bad for recurring events with gaps.
                // Improvement: Parse the calendardata again if it's a recurrence set.

                return {
                    start: Math.max(obj.firstoccurence || 0, start),
                    end: Math.min(obj.lastoccurence || 0, end),
                    type: 'BUSY'
                };
            });

            return freeBusyRanges;

        } catch (error) {
            console.error(`Error fetching FreeBusy for ${principalUri}:`, error);
            return []; // Fail safe default to Free
        }
    }

    /**
     * Ensures an 'inbox' calendar exists for the user.
     * Returns the inbox calendar info.
     */
    async ensureInbox(principalUri: string): Promise<CalendarInfo> {
        const calendars = await this.getCalendarsForUser(principalUri);
        const inbox = calendars.find(c => c.uri === 'inbox');

        if (inbox) return inbox;

        // Create Inbox
        console.log(`[Scheduling] Creating Inbox for ${principalUri}`);
        const props = {
            '{DAV:}displayname': 'Inbox',
            '{urn:ietf:params:xml:ns:caldav}calendar-description': 'Your Scheduling Inbox',
            '{urn:ietf:params:xml:ns:caldav}supported-calendar-component-set': { value: ['VEVENT', 'VTODO', 'VJOURNAL'] },
            '{urn:ietf:params:xml:ns:caldav}schedule-calendar-transp': { value: 'transparent' } // Inboxes don't block time
        };

        await this.createCalendar(principalUri, 'inbox', props);

        // Fetch again
        const newCalendars = await this.getCalendarsForUser(principalUri);
        return newCalendars.find(c => c.uri === 'inbox')!;
    }

    /**
     * Delivers a scheduling message (iTIP) to the user's Inbox.
     */
    async deliverToInbox(principalUri: string, calendarData: string, filename?: string): Promise<string | null> {
        try {
            const inbox = await this.ensureInbox(principalUri);

            // Generate a filename if not provided
            const name = filename || `itip-${Date.now()}-${Math.floor(Math.random() * 1000)}.ics`;

            return await this.createCalendarObject(inbox.id, name, calendarData);
        } catch (e) {
            console.error(`[Scheduling] Failed to deliver to inbox of ${principalUri}`, e);
            throw e;
        }
    }
}
