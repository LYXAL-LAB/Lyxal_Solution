/**
 * Core CalDAV Types adapted from Nextcloud/SabreDAV logic
 */

export enum CalendarAccess {
    READ = 1,
    READWRITE = 2, // (1 | 2)
    ADMIN = 3      // (1 | 2 | 3... technically all permissions)
}

export enum CalendarType {
    CALENDAR = 0,
    SUBSCRIPTION = 1,
    FEDERATED = 2
}

export enum Classification {
    PUBLIC = 0,
    PRIVATE = 1,
    CONFIDENTIAL = 2
}

// See CalDavBackend.php propertyMap
export interface CalendarInfo {
    id: string; // SurrealDB ID (record)
    uri: string;
    principaluri: string;
    synctoken: number;

    // WebDAV/CalDAV mapped properties
    displayname?: string;
    description?: string;
    calendarcolor?: string;
    calendarorder?: number;
    timezone?: string;

    // Components supported (VEVENT, VTODO)
    components?: string[];

    // Transparence
    transparent?: boolean;

    // Access Controls
    readonly?: boolean;
    ownerPrincipal?: string; // owner-principal

    // Metadata
    ctag?: string; // usually same as synctoken or generated
}

// Represents a row in `calendarobjects`
export interface CalendarObject {
    id: string;
    calendarid: string;
    uri: string;
    calendardata: string;
    lastmodified: number;
    etag: string;
    size: number;
    componenttype?: string;
    firstoccurence?: number;
    lastoccurence?: number;
    uid?: string;
    classification?: number;
}

export interface CalendarChange {
    uri: string;
    synctoken: number;
    operation: number; // 1=Add, 2=Modify, 3=Delete
}

export interface SchedulingObject {
    id: string;
    principaluri: string;
    uri: string;
    calendardata: string;
    lastmodified: number;
    etag: string;
    size: number;
}

export interface SubscriptionInfo {
    id: string;
    uri: string;
    principaluri: string;
    source: string; // url
    displayname?: string;
    refreshrate?: string;
    calendarcolor?: string;
    calendarorder?: number;
    striptodos?: boolean;
    stripalarms?: boolean;
    stripattachments?: boolean;
    lastmodified: number;
    synctoken: number;
}

export interface Sharee {
    href: string; // principal uri (mailto:user@example.com or /principals/users/user)
    accessLevel: CalendarAccess; // READ or READWRITE
    status: number; // 1=Accepted, 2=Declined, etc. (Simplified)
    summary?: string;
}
