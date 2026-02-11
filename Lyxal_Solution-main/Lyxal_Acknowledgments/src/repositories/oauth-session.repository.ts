import { db } from "../db";
import { logger } from "../pkg/logger";

export interface OAuthSession {
    id: string;
    user_sub: string;
    refresh_token_encrypted: string;
    access_token_expires_at: Date;
    created_at: Date;
    updated_at: Date;
}

export class OAuthSessionRepository {
    /**
     * Create or update OAuth session
     */
    async upsert(userSub: string, refreshToken: string, expiresAt: Date): Promise<OAuthSession> {
        try {
            // Check if session exists
            const existing = await db.query(
                "SELECT * FROM oauth_sessions WHERE user_sub = $userSub LIMIT 1",
                { userSub }
            );

            if ((existing[0] as any[]).length > 0) {
                // Update
                const [updated] = await db.merge((existing[0] as any[])[0].id, {
                    refresh_token_encrypted: refreshToken,
                    access_token_expires_at: expiresAt,
                    updated_at: new Date()
                });
                return updated as OAuthSession;
            } else {
                // Create
                const [created] = await db.create("oauth_sessions", {
                    user_sub: userSub,
                    refresh_token_encrypted: refreshToken,
                    access_token_expires_at: expiresAt,
                    created_at: new Date(),
                    updated_at: new Date()
                });
                return created as OAuthSession;
            }
        } catch (error) {
            logger.error(`Failed to upsert OAuth session for user ${userSub}`, error);
            throw error;
        }
    }

    /**
     * Get session by user_sub
     */
    async getByUserSub(userSub: string): Promise<OAuthSession | null> {
        try {
            const result = await db.query(
                "SELECT * FROM oauth_sessions WHERE user_sub = $userSub LIMIT 1",
                { userSub }
            );
            return (result[0] as OAuthSession[])[0] || null;
        } catch (error) {
            logger.error(`Failed to get OAuth session for user ${userSub}`, error);
            throw error;
        }
    }

    /**
     * Delete session
     */
    async delete(userSub: string): Promise<void> {
        try {
            await db.query(
                "DELETE FROM oauth_sessions WHERE user_sub = $userSub",
                { userSub }
            );
        } catch (error) {
            logger.error(`Failed to delete OAuth session for user ${userSub}`, error);
            throw error;
        }
    }

    /**
     * Delete expired sessions (cleanup)
     */
    async deleteExpired(olderThanDays: number = 37): Promise<number> {
        try {
            const result = await db.query(
                `DELETE FROM oauth_sessions WHERE access_token_expires_at < time::now() - ${olderThanDays}d`
            );
            // SurrealDB DELETE returns deleted records
            return Array.isArray(result[0]) ? (result[0] as any[]).length : 0;
        } catch (error) {
            logger.error("Failed to delete expired OAuth sessions", error);
            throw error;
        }
    }
}

export const oauthSessionRepository = new OAuthSessionRepository();
