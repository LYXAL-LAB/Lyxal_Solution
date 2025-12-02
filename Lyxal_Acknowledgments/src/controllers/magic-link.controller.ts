import { Elysia, t } from "elysia";
import { db } from "../db";
import { logger } from "../pkg/logger";
import { generateNonce } from "../pkg/crypto";

export const magicLinkController = new Elysia({ prefix: "/auth/magic-link" })
    .post("/request", async ({ body, set }) => {
        const { email } = body;

        try {
            // 1. Generate Token
            const token = generateNonce(); // Secure random string
            const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

            // 2. Store Token in DB
            await db.create("magic_link_tokens", {
                token, // In real app, hash this token!
                email,
                expires_at: expiresAt,
                created_at: new Date(),
                used: false
            });

            // 3. Send Email (Mock for now, would use pkg/email)
            logger.info(`[MOCK EMAIL] Magic Link for ${email}: http://localhost:3000/auth/magic-link/verify?token=${token}`);

            return { success: true, message: "Magic link sent" };

        } catch (error: any) {
            logger.error("Failed to request magic link", error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    }, {
        body: t.Object({
            email: t.String({ format: "email" })
        })
    })
    .get("/verify", async ({ query, set }) => {
        const { token } = query;

        try {
            // 1. Find Token
            const [record] = await db.query(
                "SELECT * FROM magic_link_tokens WHERE token = $token AND used = false AND expires_at > time::now() LIMIT 1",
                { token }
            );

            const tokenRecord = record && (record as any[])[0];

            if (!tokenRecord) {
                set.status = 401;
                return { success: false, error: "Invalid or expired token" };
            }

            // 2. Mark as used
            await db.merge(tokenRecord.id, { used: true, used_at: new Date() });

            // 3. Create Session (Mock)
            // In a real app, we would set a secure HTTP-only cookie here
            const sessionUser = {
                sub: `user_${tokenRecord.email}`, // Simple sub generation
                email: tokenRecord.email
            };

            logger.info(`User authenticated: ${sessionUser.email}`);

            return { success: true, user: sessionUser, token: "mock_session_token" };

        } catch (error: any) {
            logger.error("Failed to verify magic link", error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    }, {
        query: t.Object({
            token: t.String()
        })
    });
