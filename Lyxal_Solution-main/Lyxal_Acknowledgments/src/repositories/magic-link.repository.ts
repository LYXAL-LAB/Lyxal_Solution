import { db } from "../db";
import { logger } from "../pkg/logger";

export interface MagicLinkToken {
    id: string;
    email: string;
    token: string;
    expires_at: Date;
    used_at?: Date;
    ip_address?: string;
    user_agent?: string;
    created_at: Date;
}

export class MagicLinkRepository {
    /**
     * Create a new magic link token
     */
    async create(email: string, token: string, expiresInMinutes: number = 15, ipAddress?: string, userAgent?: string): Promise<MagicLinkToken> {
        try {
            const [result] = await db.create("magic_link_tokens", {
                email,
                token,
                expires_at: new Date(Date.now() + expiresInMinutes * 60 * 1000),
                ip_address: ipAddress || "",
                user_agent: userAgent || "",
                created_at: new Date()
            });
            return result as MagicLinkToken;
        } catch (error) {
            logger.error("Failed to create magic link token", error);
            throw error;
        }
    }

    /**
     * Get token by value (for verification)
     */
    async getByToken(token: string): Promise<MagicLinkToken | null> {
        try {
            const result = await db.query(
                "SELECT * FROM magic_link_tokens WHERE token = $token AND expires_at > time::now() AND used_at IS NONE LIMIT 1",
                { token }
            );
            return (result[0] as MagicLinkToken[])[0] || null;
        } catch (error) {
            logger.error("Failed to get magic link token", error);
            throw error;
        }
    }

    /**
     * Mark token as used
     */
    async markAsUsed(id: string): Promise<void> {
        try {
            await db.merge(id, {
                used_at: new Date()
            });
        } catch (error) {
            logger.error(`Failed to mark magic link ${id} as used`, error);
            throw error;
        }
    }

    /**
     * Delete expired tokens (cleanup)
     */
    async deleteExpired(): Promise<void> {
        try {
            await db.query("DELETE FROM magic_link_tokens WHERE expires_at < time::now()");
        } catch (error) {
            logger.error("Failed to delete expired magic links", error);
            throw error;
        }
    }

    /**
     * Count recent authentication attempts (rate limiting)
     */
    async countRecentAttempts(email: string, withinMinutes: number = 60): Promise<number> {
        try {
            const result = await db.query(
                `SELECT count() FROM magic_link_auth_attempts 
         WHERE email = $email AND attempted_at > time::now() - ${withinMinutes}m
         GROUP ALL`,
                { email }
            );
            return (result[0] as any[])[0]?.count || 0;
        } catch (error) {
            logger.error("Failed to count auth attempts", error);
            throw error;
        }
    }

    /**
     * Log authentication attempt
     */
    async logAttempt(email: string, success: boolean, ipAddress?: string): Promise<void> {
        try {
            await db.create("magic_link_auth_attempts", {
                email,
                success,
                ip_address: ipAddress || "",
                attempted_at: new Date()
            });
        } catch (error) {
            logger.error("Failed to log auth attempt", error);
            throw error;
        }
    }
}

export const magicLinkRepository = new MagicLinkRepository();
