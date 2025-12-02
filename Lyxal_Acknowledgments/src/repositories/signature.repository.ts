import { db } from "../db";
import { logger } from "../pkg/logger";

export interface Signature {
    id: string;
    doc_id: string;
    user_sub: string;
    user_email: string;
    user_name?: string;
    signed_at: Date;
    doc_checksum?: string;
    payload_hash: string;
    signature: string;
    nonce: string;
    created_at: Date;
    referer: string;
    prev_hash?: string;
    hash_version?: number;
    doc_deleted_at?: Date;
    doc_title?: string;
    doc_url?: string;
}

export class SignatureRepository {
    /**
     * Create a new signature record
     */
    async create(signature: Omit<Signature, "id" | "created_at">): Promise<Signature> {
        try {
            const [result] = await db.create("signatures", {
                ...signature,
                created_at: new Date()
            });
            return result as Signature;
        } catch (error) {
            logger.error("Failed to create signature", error);
            throw error;
        }
    }

    /**
     * Get signature by document and user
     */
    async getByDocAndUser(docId: string, userSub: string): Promise<Signature | null> {
        try {
            const result = await db.query(
                `SELECT s.*, d.title AS doc_title, d.url AS doc_url, d.deleted_at AS doc_deleted_at
         FROM signatures s
         LEFT JOIN documents d ON s.doc_id = d.doc_id
         WHERE s.doc_id = $docId AND s.user_sub = $userSub LIMIT 1`,
                { docId, userSub }
            );
            return (result[0] as Signature[])[0] || null;
        } catch (error) {
            logger.error(`Failed to get signature for doc ${docId} user ${userSub}`, error);
            throw error;
        }
    }

    /**
     * Get all signatures for a document
     */
    async getByDoc(docId: string): Promise<Signature[]> {
        try {
            const result = await db.query(
                `SELECT s.*, d.title AS doc_title, d.url AS doc_url, d.deleted_at AS doc_deleted_at
         FROM signatures s
         LEFT JOIN documents d ON s.doc_id = d.doc_id
         WHERE s.doc_id = $docId
         ORDER BY s.created_at DESC`,
                { docId }
            );
            return result[0] as Signature[];
        } catch (error) {
            logger.error(`Failed to get signatures for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Get all signatures by user
     */
    async getByUser(userSub: string): Promise<Signature[]> {
        try {
            const result = await db.query(
                `SELECT s.*, d.title AS doc_title, d.url AS doc_url, d.deleted_at AS doc_deleted_at
         FROM signatures s
         LEFT JOIN documents d ON s.doc_id = d.doc_id
         WHERE s.user_sub = $userSub
         ORDER BY s.created_at DESC`,
                { userSub }
            );
            return result[0] as Signature[];
        } catch (error) {
            logger.error(`Failed to get signatures for user ${userSub}`, error);
            throw error;
        }
    }

    /**
     * Check if signature exists
     */
    async existsByDocAndUser(docId: string, userSub: string): Promise<boolean> {
        try {
            const result = await db.query(
                "SELECT count() FROM signatures WHERE doc_id = $docId AND user_sub = $userSub GROUP ALL",
                { docId, userSub }
            );
            return ((result[0] as any[])[0]?.count || 0) > 0;
        } catch (error) {
            logger.error("Failed to check signature existence", error);
            throw error;
        }
    }

    /**
     * Check if user has signed (by sub or email)
     */
    async checkUserSignatureStatus(docId: string, userIdentifier: string): Promise<boolean> {
        try {
            const result = await db.query(
                `SELECT count() FROM signatures 
         WHERE doc_id = $docId AND (user_sub = $id OR string::lowercase(user_email) = string::lowercase($id))
         GROUP ALL`,
                { docId, id: userIdentifier }
            );
            return ((result[0] as any[])[0]?.count || 0) > 0;
        } catch (error) {
            logger.error("Failed to check user signature status", error);
            throw error;
        }
    }

    /**
     * Get last signature for hash chain linking
     */
    async getLastSignature(docId: string): Promise<Signature | null> {
        try {
            const result = await db.query(
                `SELECT s.*, d.title AS doc_title, d.url AS doc_url
         FROM signatures s
         LEFT JOIN documents d ON s.doc_id = d.doc_id
         WHERE s.doc_id = $docId
         ORDER BY s.id DESC
         LIMIT 1`,
                { docId }
            );
            return (result[0] as Signature[])[0] || null;
        } catch (error) {
            logger.error(`Failed to get last signature for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Get all signatures ordered for chain verification
     */
    async getAllSignaturesOrdered(): Promise<Signature[]> {
        try {
            const result = await db.query(
                `SELECT s.*, d.title AS doc_title, d.url AS doc_url
         FROM signatures s
         LEFT JOIN documents d ON s.doc_id = d.doc_id
         ORDER BY s.id ASC`
            );
            return result[0] as Signature[];
        } catch (error) {
            logger.error("Failed to get all signatures ordered", error);
            throw error;
        }
    }

    /**
     * Update prev_hash (for chain reconstruction)
     */
    async updatePrevHash(id: string, prevHash: string | null): Promise<void> {
        try {
            await db.merge(id, { prev_hash: prevHash });
        } catch (error) {
            logger.error(`Failed to update prev_hash for ${id}`, error);
            throw error;
        }
    }
}

export const signatureRepository = new SignatureRepository();
