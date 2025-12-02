import { db } from "../db";
import { logger } from "../pkg/logger";

export class CleanupWorker {
    private isRunning = false;
    private intervalId?: Timer;

    start(intervalMs: number = 3600000) { // Default 1 hour
        if (this.isRunning) return;
        this.isRunning = true;
        logger.info("Cleanup Worker started");

        this.intervalId = setInterval(() => this.runCleanup(), intervalMs);
    }

    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = undefined;
        }
        this.isRunning = false;
        logger.info("Cleanup Worker stopped");
    }

    private async runCleanup() {
        try {
            logger.info("Running scheduled cleanup...");

            // 1. Delete expired Magic Link tokens
            await db.query("DELETE FROM magic_link_tokens WHERE expires_at < time::now()");

            // 2. Delete expired OAuth sessions (older than 37 days)
            // "DELETE FROM oauth_sessions WHERE access_token_expires_at < time::now() - 37d"
            await db.query("DELETE FROM oauth_sessions WHERE access_token_expires_at < time::now() - 37d");

            logger.info("Cleanup completed");

        } catch (error) {
            logger.error("Cleanup Worker failed", error);
        }
    }
}

export const cleanupWorker = new CleanupWorker();
