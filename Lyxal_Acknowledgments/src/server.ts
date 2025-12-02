import { Elysia } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { logger } from "./pkg/logger";
import { initDB } from "./db";
import { signatureController } from "./controllers/signature.controller";
import { documentController } from "./controllers/document.controller";
import { magicLinkController } from "./controllers/magic-link.controller";
import { reminderController } from "./controllers/reminder.controller";

// Initialize SurrealDB connection
initDB();

const app = new Elysia()
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
        logger.error(`Request failed: ${code}`, error);
        return {
            success: false,
            error: error.message,
            code: code
        };
    })
    .use(signatureController)
    .use(documentController)
    .use(magicLinkController)
    .use(reminderController)
    .get("/", () => ({ status: "ok", service: "Lyxal_Acknowledgments" }))
    .listen(3000);

logger.info(`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`);
