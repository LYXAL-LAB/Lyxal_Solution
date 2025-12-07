import { getSurrealClient } from "@lyxal/surreal";
import type { Surreal } from "surrealdb";

export class DatabaseService {
    private static instance: DatabaseService;
    private db: Surreal | null = null;

    private constructor() { }

    public static getInstance(): DatabaseService {
        if (!DatabaseService.instance) {
            DatabaseService.instance = new DatabaseService();
        }
        return DatabaseService.instance;
    }

    public async connect(
        namespace: string = 'lyxal',
        database: string = 'calendar'
    ): Promise<void> {
        try {
            // Using the shared singleton client from @lyxal/surreal
            // The connection logic (url, auth) is handled by the shared client configuration
            this.db = await getSurrealClient({ namespace, database });
            console.log(`[Lyxal_Dav] Connected to SurrealDB (ns: ${namespace}, db: ${database})`);
        } catch (error) {
            console.error('[Lyxal_Dav] Failed to connect to SurrealDB:', error);
            throw error;
        }
    }

    public getClient(): Surreal {
        if (!this.db) {
            throw new Error("Database not connected. Call connect() first.");
        }
        return this.db;
    }

    public async close(): Promise<void> {
        // We generally don't want to close the shared pool, but if needed:
        if (this.db) {
            await this.db.close();
        }
    }
}

