import { db } from "../db";
import { logger } from "../pkg/logger";

export interface ReminderLog {
    id: string;
    doc_id: string;
    recipient_email: string;
    sent_by: string;
    sent_at: Date;
    status: "sent" | "failed";
    error_message?: string;
}

export class ReminderRepository {
    /**
     * Log a reminder sent
     */
    async logReminder(
        docId: string,
        recipientEmail: string,
        sentBy: string,
        status: "sent" | "failed",
        errorMessage?: string
    ): Promise<ReminderLog> {
        try {
            const [log] = await db.create("reminder_logs", {
                doc_id: docId,
                recipient_email: recipientEmail,
                sent_by: sentBy,
                sent_at: new Date(),
                status,
                error_message: errorMessage || ""
            });
            return log as ReminderLog;
        } catch (error) {
            logger.error("Failed to log reminder", error);
            throw error;
        }
    }

    /**
     * Get reminder history for a document
     */
    async getByDocId(docId: string): Promise<ReminderLog[]> {
        try {
            const result = await db.query(
                "SELECT * FROM reminder_logs WHERE doc_id = $docId ORDER BY sent_at DESC",
                { docId }
            );
            return result[0] as ReminderLog[];
        } catch (error) {
            logger.error(`Failed to get reminders for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Get reminder history for a specific signer
     */
    async getByDocAndEmail(docId: string, email: string): Promise<ReminderLog[]> {
        try {
            const result = await db.query(
                "SELECT * FROM reminder_logs WHERE doc_id = $docId AND recipient_email = $email ORDER BY sent_at DESC",
                { docId, email }
            );
            return result[0] as ReminderLog[];
        } catch (error) {
            logger.error(`Failed to get reminders for ${email} on doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Get last reminder sent to an email for a document
     */
    async getLastReminderSent(docId: string, email: string): Promise<ReminderLog | null> {
        try {
            const result = await db.query(
                "SELECT * FROM reminder_logs WHERE doc_id = $docId AND recipient_email = $email ORDER BY sent_at DESC LIMIT 1",
                { docId, email }
            );
            return (result[0] as ReminderLog[])[0] || null;
        } catch (error) {
            logger.error("Failed to get last reminder", error);
            throw error;
        }
    }

    /**
     * Count reminders sent to an email for a document
     */
    async countForDocAndEmail(docId: string, email: string): Promise<number> {
        try {
            const result = await db.query(
                "SELECT count() FROM reminder_logs WHERE doc_id = $docId AND recipient_email = $email GROUP ALL",
                { docId, email }
            );
            return (result[0] as any[])[0]?.count || 0;
        } catch (error) {
            logger.error("Failed to count reminders", error);
            throw error;
        }
    }
}

export const reminderRepository = new ReminderRepository();
