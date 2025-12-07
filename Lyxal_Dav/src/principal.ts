
/**
 * PrincipalBackend
 * 
 * Manages "Principals" (Users, Groups, Resources).
 * Maps a Principal URI (e.g. principals/users/admin) to their information (email, displayname).
 */
import { DatabaseService } from './database';

export interface PrincipalInfo {
    uri: string;
    displayname?: string;
    email?: string;
    '{http://sabredav.org/ns}email-address'?: string;
    'calendar-home-set'?: string;
    'schedule-outbox-URL'?: string;
    'schedule-inbox-URL'?: string;
}

export class PrincipalBackend {
    private db: DatabaseService;

    constructor() {
        this.db = DatabaseService.getInstance();
    }

    async getPrincipalByPath(path: string): Promise<PrincipalInfo | null> {
        // For development, we return a mock principal based on the path
        if (path.startsWith('principals/users/')) {
            const username = path.split('/').pop();
            return {
                uri: path,
                displayname: username,
                '{http://sabredav.org/ns}email-address': `${username}@lyxal.local`,
                'calendar-home-set': `/calendars/${username}/`,
                'schedule-outbox-URL': `/calendars/${username}/`,
                'schedule-inbox-URL': `/calendars/${username}/inbox/`,
            };
        }
        return null;
    }
}
