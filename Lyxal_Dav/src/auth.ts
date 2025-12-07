
/**
 * AuthBackend
 * 
 * Handles user authentication (Basic/Bearer).
 * For now, we accept ANY user as long as they have a Principal URI, 
 * or we implement a simple check against SurrealDB users if available.
 */
import { DatabaseService } from './database';

export class AuthBackend {
    private db: DatabaseService;

    constructor() {
        this.db = DatabaseService.getInstance();
    }

    /**
     * Authenticates the user based on the request headers.
     * Returns the Principal URI if successful, or null.
     */
    async authenticate(req: Request): Promise<string | null> {
        const authHeader = req.headers.get('Authorization');

        if (!authHeader) {
            return null;
        }

        const [scheme, credentials] = authHeader.split(' ');

        if (scheme === 'Basic') {
            return await this.checkBasicAuth(credentials);
        } else if (scheme === 'Bearer') {
            return await this.checkBearerAuth(credentials);
        }

        return null;
    }

    private async checkBasicAuth(credentials: string): Promise<string | null> {
        const decoded = atob(credentials);
        const [username, password] = decoded.split(':');

        // TODO: Validate against DB
        // For development/MVP: We trust the username and return their principal URI
        console.log(`[Auth] Basic Login attempt: ${username}`);

        // In a real system: verify password hash
        return `principals/users/${username}`;
    }

    private async checkBearerAuth(token: string): Promise<string | null> {
        // TODO: Validate JWT/Reference token
        console.log(`[Auth] Bearer Login attempt`);
        return `principals/users/admin`; // Mock
    }
}
