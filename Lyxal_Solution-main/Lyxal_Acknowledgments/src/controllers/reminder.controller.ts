import { Elysia, t } from "elysia";
import { db } from "../db";
import { logger } from "../pkg/logger";

export const reminderController = new Elysia({ prefix: "/reminders" })
    .post("/send", async ({ body, set }) => {
        const { doc_id } = body;

        try {
            // 1. Get Document and Expected Signers
            const [doc] = await db.select(`documents:${doc_id}`);
            if (!doc) throw new Error("Document not found");

            const signers = await db.query(
                "SELECT * FROM expected_signers WHERE doc_id = $doc_id",
                { doc_id }
            );

            // 2. Check who has already signed
            const signatures = await db.query(
                "SELECT user_email FROM signatures WHERE doc_id = $doc_id",
                { doc_id }
            );

            const signedEmails = new Set((signatures[0] as any[]).map((s: any) => s.user_email));

            // 3. Filter pending signers
            const pendingSigners = (signers[0] as any[]).filter((s: any) => !signedEmails.has(s.email));

            if (pendingSigners.length === 0) {
                return { success: true, message: "No pending signers" };
            }

            // 4. Queue Emails (Mock)
            for (const signer of pendingSigners) {
                // Insert into email_queue
                await db.create("email_queue", {
                    recipient: signer.email,
                    subject: `Reminder: Please sign ${doc.title}`,
                    body: "...", // Template rendering would go here
                    status: "queued",
                    created_at: new Date()
                });
                logger.info(`Queued reminder for ${signer.email}`);
            }

            return { success: true, count: pendingSigners.length };

        } catch (error: any) {
            logger.error("Failed to send reminders", error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    }, {
        body: t.Object({
            doc_id: t.String()
        })
    });
