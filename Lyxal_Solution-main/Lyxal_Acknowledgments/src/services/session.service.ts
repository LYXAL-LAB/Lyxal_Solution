import { db } from "../db";
import { logger } from "../pkg/logger";
import { User } from "../models/user";

export class SessionService {
    // In a real app, this would wrap cookie management (Elysia's cookie plugin)
    // For now, it provides helper methods to interact with session data in DB

    async createOAuthSession(user: User, refreshToken: string, expiresAt: Date) {
        try {
            // Create OAuth session record
            const [record] = await db.create("oauth_sessions", {
                user_sub: user.sub,
                refresh_token_encrypted: refreshToken, // Should be encrypted!
                access_token_expires_at: expiresAt,
                created_at: new Date(),
                updated_at: new Date()
            });
            return record;
        } catch (error) {
            logger.error("Failed to create OAuth session", error);
            throw error;
        }
    }

    async getOAuthSession(sessionId: string) {
        try {
            const [session] = await db.select(`oauth_sessions:${sessionId}`);
            return session;
        } catch (error) {
            return null;
        }
    }
}

export const sessionService = new SessionService();
