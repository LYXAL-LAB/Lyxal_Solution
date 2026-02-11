import { db } from "../db";
import { logger } from "../pkg/logger";

export interface EmailQueueEntry {
    id: string;
    recipient: string;
    subject: string;
    body: string;
    template_name?: string;
    template_data?: any;
    status: "queued" | "sent" | "failed";
    retries: number;
    max_retries: number;
    next_retry_at: Date;
    sent_at?: Date;
    error_message?: string;
    created_at: Date;
    updated_at: Date;
}

export class EmailQueueRepository {
    /**
     * Enqueue an email for sending
     */
    async enqueue(
        recipient: string,
        subject: string,
        body: string,
        templateName?: string,
        templateData?: any
    ): Promise<EmailQueueEntry> {
        try {
            const [entry] = await db.create("email_queue", {
                recipient,
                subject,
                body,
                template_name: templateName || "",
                template_data: templateData || {},
                status: "queued",
                retries: 0,
                max_retries: 3,
                next_retry_at: new Date(),
                created_at: new Date(),
                updated_at: new Date()
            });
            return entry as EmailQueueEntry;
        } catch (error) {
            logger.error("Failed to enqueue email", error);
            throw error;
        }
    }

    /**
     * Get pending emails ready for sending
     */
    async getPending(limit: number = 10): Promise<EmailQueueEntry[]> {
        try {
            const result = await db.query(
                `SELECT * FROM email_queue 
         WHERE status = 'queued' AND next_retry_at <= time::now()
         LIMIT $limit`,
                { limit }
            );
            return result[0] as EmailQueueEntry[];
        } catch (error) {
            logger.error("Failed to get pending emails", error);
            throw error;
        }
    }

    /**
     * Mark email as sent
     */
    async markAsSent(id: string): Promise<void> {
        try {
            await db.merge(id, {
                status: "sent",
                sent_at: new Date(),
                updated_at: new Date()
            });
        } catch (error) {
            logger.error(`Failed to mark email ${id} as sent`, error);
            throw error;
        }
    }

    /**
     * Mark email as failed and schedule retry
     */
    async markAsFailed(id: string, errorMessage: string, retryDelay: number = 60000): Promise<void> {
        try {
            const [entry] = await db.select(id);
            const current = entry as EmailQueueEntry;
            const newRetries = (current.retries || 0) + 1;

            if (newRetries >= (current.max_retries || 3)) {
                // Max retries reached
                await db.merge(id, {
                    status: "failed",
                    error_message: errorMessage,
                    updated_at: new Date()
                });
            } else {
                // Schedule retry
                await db.merge(id, {
                    retries: newRetries,
                    error_message: errorMessage,
                    next_retry_at: new Date(Date.now() + retryDelay * Math.pow(2, newRetries)),
                    updated_at: new Date()
                });
            }
        } catch (error) {
            logger.error(`Failed to mark email ${id} as failed`, error);
            throw error;
        }
    }

    /**
     * Delete old processed emails (cleanup)
     */
    async deleteOldProcessed(olderThanDays: number = 30): Promise<void> {
        try {
            await db.query(
                `DELETE FROM email_queue 
         WHERE (status = 'sent' OR status = 'failed') 
         AND updated_at < time::now() - ${olderThanDays}d`
            );
        } catch (error) {
            logger.error("Failed to delete old emails", error);
            throw error;
        }
    }
}

export const emailQueueRepository = new EmailQueueRepository();
