import { Elysia } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { logger } from "./pkg/logger";
import { initDB } from "./db";
import { signatureController } from "./controllers/signature.controller";
import { documentController } from "./controllers/document.controller";
import { magicLinkController } from "./controllers/magic-link.controller";
import { reminderController } from "./controllers/reminder.controller";
import { oauthController } from "./controllers/oauth.controller";
import { adminController } from "./controllers/admin.controller";
import { userController } from "./controllers/user.controller";
import { emailWorker } from "./workers/email.worker";
import { cleanupWorker } from "./workers/cleanup.worker";
import { webhookWorker } from "./workers/webhook.worker";
import { i18nPlugin } from "./pkg/i18n/middleware";
import { i18n } from "./pkg/i18n";
import { config } from "./config";

// Initialize SurrealDB connection
initDB().then(async () => {
    // Start background workers after DB is connected
    emailWorker.start();
    cleanupWorker.start();
    webhookWorker.start();

    // Load translations
    await i18n.loadTranslations("./locales");
    logger.info("Translations loaded");

    // Load email templates
    await import("./services/email-renderer.service").then(m => m.emailRenderer.loadTemplates());
});

export const app = new Elysia()
    .use(swagger({
        documentation: {
            info: {
                title: "Lyxal Acknowledgments API",
                version: "1.0.0",
                description: "API for Proof of Read/Signature management"
            }
        }
    }))
    .onError(({ code, error }) => {
        const errorMessage = error instanceof Error ? error.message : "Unknown error";
        logger.error(`Request failed: ${code}`, error);
        return {
            success: false,
            error: errorMessage,
            code: code
        };
    })
    .use(i18nPlugin)
    .use(userController)
    .use(adminController)
    .use(signatureController)
    .use(documentController)
    .use(magicLinkController)
    .use(oauthController)
    .use(reminderController)
    .get("/", () => ({ status: "ok", service: "Lyxal_Acknowledgments" }));
