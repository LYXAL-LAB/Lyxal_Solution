import { db } from "../db";
import { logger } from "../pkg/logger";
import { emailService } from "../services/email.service";

export class EmailWorker {
    private isRunning = false;
    private intervalId?: Timer;

    start(intervalMs: number = 5000) {
        if (this.isRunning) return;
        this.isRunning = true;
        logger.info("Email Worker started");

        this.intervalId = setInterval(() => this.processQueue(), intervalMs);
    }

    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = undefined;
        }
        this.isRunning = false;
        logger.info("Email Worker stopped");
    }

    private async processQueue() {
        try {
            // 1. Fetch pending emails (Limit 10 to avoid overload)
            // Transactional select and update would be better, but for now we do simple select
            const pending = await db.query(
                "SELECT * FROM email_queue WHERE status = 'queued' AND next_retry_at <= time::now() LIMIT 10"
            );

            const emails = pending[0] as any[];

            if (!emails || emails.length === 0) return;

            logger.debug(`Processing ${emails.length} queued emails`);

            for (const email of emails) {
                try {
                    // 2. Send Email
                    await emailService.send({
                        to: email.recipient,
                        subject: email.subject,
                        html: email.body, // Assuming body contains HTML
                    });

                    // 3. Mark as Sent
                    await db.merge(email.id, {
                        status: "sent",
                        sent_at: new Date(),
                        updated_at: new Date()
                    });

                } catch (error: any) {
                    logger.error(`Failed to process email ${email.id}`, error);

                    // 4. Handle Retry Logic
                    const retries = (email.retries || 0) + 1;
                    const maxRetries = email.max_retries || 3;

                    if (retries >= maxRetries) {
                        await db.merge(email.id, {
                            status: "failed",
                            error_message: error.message,
                            updated_at: new Date()
                        });
                    } else {
                        // Exponential backoff
                        const delay = Math.pow(2, retries) * 60 * 1000; // 2m, 4m, 8m...
                        await db.merge(email.id, {
                            retries: retries,
                            next_retry_at: new Date(Date.now() + delay),
                            error_message: error.message,
                            updated_at: new Date()
                        });
                    }
                }
            }

        } catch (error) {
            logger.error("Email Worker loop failed", error);
        }
    }
}

export const emailWorker = new EmailWorker();
