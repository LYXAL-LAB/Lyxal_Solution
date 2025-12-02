import { db } from "../db";
import { logger } from "../pkg/logger";

export interface ContactInfo {
    email: string;
    name?: string;
}

export interface ExpectedSigner {
    id: string;
    doc_id: string;
    email: string;
    name?: string;
    added_at: Date;
    added_by: string;
    notes?: string;
}

export interface ExpectedSignerWithStatus extends ExpectedSigner {
    has_signed: boolean;
    signed_at?: Date;
    user_name?: string;
    last_reminder_sent?: Date;
    reminder_count: number;
    days_since_added: number;
    days_since_last_reminder?: number;
}

export interface DocCompletionStats {
    doc_id: string;
    expected_count: number;
    signed_count: number;
    pending_count: number;
    completion_rate: number;
}

export class ExpectedSignerRepository {
    /**
     * Batch add expected signers (conflict-safe)
     */
    async addExpected(docId: string, contacts: ContactInfo[], addedBy: string): Promise<void> {
        if (contacts.length === 0) return;

        try {
            // Batch insert with deduplication
            for (const contact of contacts) {
                // SurrealDB doesn't have ON CONFLICT, so we check first
                const existing = await db.query(
                    "SELECT id FROM expected_signers WHERE doc_id = $docId AND email = $email LIMIT 1",
                    { docId, email: contact.email }
                );

                if ((existing[0] as any[]).length === 0) {
                    await db.create("expected_signers", {
                        doc_id: docId,
                        email: contact.email,
                        name: contact.name || "",
                        added_by: addedBy,
                        added_at: new Date(),
                        notes: ""
                    });
                }
            }
        } catch (error) {
            logger.error(`Failed to add expected signers for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * List all expected signers for a document
     */
    async listByDocId(docId: string): Promise<ExpectedSigner[]> {
        try {
            const result = await db.query(
                "SELECT * FROM expected_signers WHERE doc_id = $docId ORDER BY added_at ASC",
                { docId }
            );
            return result[0] as ExpectedSigner[];
        } catch (error) {
            logger.error(`Failed to list expected signers for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * List expected signers with signature status and reminder metrics
     */
    async listWithStatusByDocId(docId: string): Promise<ExpectedSignerWithStatus[]> {
        try {
            // Complex query with JOINs and aggregations
            const result = await db.query(
                `SELECT 
          es.*,
          (SELECT count() FROM signatures WHERE doc_id = es.doc_id AND user_email = es.email GROUP ALL)[0].count > 0 AS has_signed,
          (SELECT signed_at FROM signatures WHERE doc_id = es.doc_id AND user_email = es.email LIMIT 1)[0].signed_at AS signed_at,
          (SELECT user_name FROM signatures WHERE doc_id = es.doc_id AND user_email = es.email LIMIT 1)[0].user_name AS user_name,
          (SELECT sent_at FROM reminder_logs WHERE doc_id = es.doc_id AND recipient_email = es.email ORDER BY sent_at DESC LIMIT 1)[0].sent_at AS last_reminder_sent,
          (SELECT count() FROM reminder_logs WHERE doc_id = es.doc_id AND recipient_email = es.email AND status = 'sent' GROUP ALL)[0].count AS reminder_count,
          time::duration::days(time::now() - es.added_at) AS days_since_added
        FROM expected_signers es
        WHERE es.doc_id = $docId
        ORDER BY has_signed DESC, es.added_at ASC`,
                { docId }
            );
            return result[0] as ExpectedSignerWithStatus[];
        } catch (error) {
            logger.error(`Failed to list expected signers with status for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Remove a specific expected signer
     */
    async remove(docId: string, email: string): Promise<void> {
        try {
            await db.query(
                "DELETE FROM expected_signers WHERE doc_id = $docId AND email = $email",
                { docId, email }
            );
        } catch (error) {
            logger.error(`Failed to remove expected signer ${email} from doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Remove all expected signers for a document
     */
    async removeAllForDoc(docId: string): Promise<void> {
        try {
            await db.query("DELETE FROM expected_signers WHERE doc_id = $docId", { docId });
        } catch (error) {
            logger.error(`Failed to remove all expected signers for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Check if email is in expected signers list
     */
    async isExpected(docId: string, email: string): Promise<boolean> {
        try {
            const result = await db.query(
                "SELECT count() FROM expected_signers WHERE doc_id = $docId AND email = $email GROUP ALL",
                { docId, email }
            );
            return ((result[0] as any[])[0]?.count || 0) > 0;
        } catch (error) {
            logger.error("Failed to check if email is expected", error);
            throw error;
        }
    }

    /**
     * Get completion statistics for a document
     */
    async getStats(docId: string): Promise<DocCompletionStats> {
        try {
            const result = await db.query(
                `SELECT 
          count() AS expected_count,
          (SELECT count() FROM (
            SELECT es.email FROM expected_signers es
            WHERE es.doc_id = $docId
            AND es.email IN (SELECT VALUE user_email FROM signatures WHERE doc_id = $docId)
          ) GROUP ALL)[0].count AS signed_count
        FROM expected_signers
        WHERE doc_id = $docId
        GROUP ALL`,
                { docId }
            );

            const data = (result[0] as any[])[0];
            const expectedCount = data?.expected_count || 0;
            const signedCount = data?.signed_count || 0;
            const pendingCount = expectedCount - signedCount;
            const completionRate = expectedCount > 0 ? (signedCount / expectedCount) * 100 : 0;

            return {
                doc_id: docId,
                expected_count: expectedCount,
                signed_count: signedCount,
                pending_count: pendingCount,
                completion_rate: completionRate
            };
        } catch (error) {
            logger.error(`Failed to get stats for doc ${docId}`, error);
            throw error;
        }
    }
}

export const expectedSignerRepository = new ExpectedSignerRepository();
