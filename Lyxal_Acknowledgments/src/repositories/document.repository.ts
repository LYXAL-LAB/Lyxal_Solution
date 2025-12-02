import { db } from "../db";
import { logger } from "../pkg/logger";
import { Document, DocumentInput } from "../models/document";

export class DocumentRepository {
    /**
     * Create a new document with metadata
     */
    async create(docId: string, input: DocumentInput, createdBy: string): Promise<Document> {
        try {
            const [doc] = await db.create(`documents:${docId}`, {
                doc_id: docId,
                title: input.title,
                url: input.url,
                checksum: input.checksum || "",
                checksum_algorithm: input.checksumAlgorithm || "SHA-256",
                description: input.description || "",
                created_by: createdBy,
                created_at: new Date(),
                updated_at: new Date(),
                deleted_at: null
            });
            return doc as Document;
        } catch (error) {
            logger.error(`Failed to create document ${docId}`, error);
            throw error;
        }
    }

    /**
     * Get document by ID (exclude soft-deleted)
     */
    async getByDocId(docId: string): Promise<Document | null> {
        try {
            const result = await db.query(
                "SELECT * FROM documents WHERE doc_id = $docId AND deleted_at IS NONE LIMIT 1",
                { docId }
            );
            return (result[0] as Document[])[0] || null;
        } catch (error) {
            logger.error(`Failed to get document ${docId}`, error);
            throw error;
        }
    }

    /**
     * Find document by reference (URL, path, or doc_id)
     */
    async findByReference(ref: string, refType: "url" | "path" | "reference"): Promise<Document | null> {
        try {
            let query = "";
            if (refType === "url" || refType === "path") {
                query = "SELECT * FROM documents WHERE url = $ref AND deleted_at IS NONE LIMIT 1";
            } else {
                query = "SELECT * FROM documents WHERE doc_id = $ref AND deleted_at IS NONE LIMIT 1";
            }

            const result = await db.query(query, { ref });
            return (result[0] as Document[])[0] || null;
        } catch (error) {
            logger.error(`Failed to find document by ${refType}: ${ref}`, error);
            throw error;
        }
    }

    /**
     * Update document metadata
     */
    async update(docId: string, input: DocumentInput): Promise<Document> {
        try {
            const [doc] = await db.merge(`documents:${docId}`, {
                title: input.title,
                url: input.url,
                checksum: input.checksum || "",
                checksum_algorithm: input.checksumAlgorithm || "SHA-256",
                description: input.description || "",
                updated_at: new Date()
            });
            return doc as Document;
        } catch (error) {
            logger.error(`Failed to update document ${docId}`, error);
            throw error;
        }
    }

    /**
     * Upsert document (create or update atomically)
     */
    async createOrUpdate(docId: string, input: DocumentInput, createdBy: string): Promise<Document> {
        const existing = await this.getByDocId(docId);
        if (existing) {
            return this.update(docId, input);
        } else {
            return this.create(docId, input, createdBy);
        }
    }

    /**
     * Soft-delete document
     */
    async delete(docId: string): Promise<void> {
        try {
            await db.merge(`documents:${docId}`, {
                deleted_at: new Date()
            });
        } catch (error) {
            logger.error(`Failed to delete document ${docId}`, error);
            throw error;
        }
    }

    /**
     * List documents with pagination (excluding soft-deleted)
     */
    async list(limit: number, offset: number): Promise<Document[]> {
        try {
            const result = await db.query(
                "SELECT * FROM documents WHERE deleted_at IS NONE ORDER BY created_at DESC LIMIT $limit START $offset",
                { limit, offset }
            );
            return result[0] as Document[];
        } catch (error) {
            logger.error("Failed to list documents", error);
            throw error;
        }
    }
}

export const documentRepository = new DocumentRepository();
