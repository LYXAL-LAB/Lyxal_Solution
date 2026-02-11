import { Elysia, t } from "elysia";
import { db } from "../db";
import { logger } from "../pkg/logger";
import { generateCodeVerifier, generateCodeChallenge } from "../pkg/crypto";
import { randomUUID } from "crypto";
import { config } from "../config";

// Simple in-memory store for OAuth state (in production, use Redis or DB)
const stateStore = new Map<string, { verifier: string, nextURL: string }>();

export const oauthController = new Elysia({ prefix: "/auth/oauth" })
    .get("/login", ({ query, set, redirect }) => {
        const { provider, next } = query;

        if (!provider) {
            set.status = 400;
            return { success: false, error: "Provider required" };
        }

        if (!config.auth.oauthEnabled) {
            set.status = 403;
            return { success: false, error: "OAuth is not enabled" };
        }

        // 1. Generate PKCE
        const verifier = generateCodeVerifier();
        const challenge = generateCodeChallenge(verifier);
        const state = randomUUID();

        // 2. Store state (TTL should be implemented)
        stateStore.set(state, { verifier, nextURL: next || "/" });

        // 3. Build Auth URL using config
        const redirectUri = `${config.app.baseURL}/auth/oauth/callback`;
        const scopes = config.oauth.scopes.join(" ");

        const authUrl = `${config.oauth.authUrl}?response_type=code&client_id=${config.oauth.clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&state=${state}&code_challenge=${challenge}&code_challenge_method=S256&scope=${encodeURIComponent(scopes)}`;

        logger.info(`Starting OAuth flow for ${provider}`);
        return redirect(authUrl);
    }, {
        query: t.Object({
            provider: t.String(),
            next: t.Optional(t.String())
        })
    })
    .get("/callback", async ({ query, set }) => {
        const { code, state } = query;

        if (!code || !state) {
            set.status = 400;
            return { success: false, error: "Invalid callback parameters" };
        }

        // 1. Verify State
        const stored = stateStore.get(state);
        if (!stored) {
            set.status = 400;
            return { success: false, error: "Invalid or expired state" };
        }
        stateStore.delete(state); // Consume state

        try {
            // 2. Exchange Code for Token using config
            const tokenResponse = await fetch(config.oauth.tokenUrl, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({
                    grant_type: "authorization_code",
                    code,
                    redirect_uri: `${config.app.baseURL}/auth/oauth/callback`,
                    client_id: config.oauth.clientId,
                    client_secret: config.oauth.clientSecret,
                    code_verifier: stored.verifier
                })
            });

            const tokens = await tokenResponse.json();

            // 3. Fetch user info
            const userResponse = await fetch(config.oauth.userInfoUrl, {
                headers: { Authorization: `Bearer ${tokens.access_token}` }
            });
            const userData = await userResponse.json();

            const user = {
                sub: userData.sub || userData.id,
                email: userData.email,
                name: userData.name || userData.display_name
            };

            // 4. Store refresh token if exists
            if (tokens.refresh_token) {
                await db.create("oauth_sessions", {
                    user_sub: user.sub,
                    refresh_token_encrypted: tokens.refresh_token, // Should encrypt!
                    access_token_expires_at: new Date(Date.now() + tokens.expires_in * 1000),
                    created_at: new Date()
                });
            }

            logger.info(`OAuth login successful for ${user.email}`);

            // 5. Redirect to Next URL
            return Response.redirect(stored.nextURL);

        } catch (error: any) {
            logger.error("OAuth callback failed", error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    }, {
        query: t.Object({
            code: t.String(),
            state: t.String()
        })
    });
