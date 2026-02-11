import { Elysia, t } from "elysia";
import { db } from "../db";
import { logger } from "../pkg/logger";

export const documentController = new Elysia({ prefix: "/documents" })
    .post("/", async ({ body, set }) => {
        const { title, url, checksum, checksum_algorithm, description, created_by } = body;

        try {
            // 1. Generate ID using SurrealDB function
            const [idResult] = await db.query("RETURN fn::generate_doc_id()");
            const docId = idResult as string;

            // 2. Create Document
            const [created] = await db.create("documents", {
                id: docId,
                title,
                url,
                checksum,
                checksum_algorithm: checksum_algorithm || "SHA-256",
                description,
                created_by, // User sub from session
                created_at: new Date(),
                updated_at: new Date()
            });

            logger.info(`Document created: ${docId}`);
            return { success: true, data: created };

        } catch (error: any) {
            logger.error("Failed to create document", error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    }, {
        body: t.Object({
            title: t.String(),
            url: t.String(),
            checksum: t.String(),
            checksum_algorithm: t.Optional(t.String()),
            description: t.Optional(t.String()),
            created_by: t.String() // In real app, get from session
        })
    })
    .get("/:id", async ({ params: { id }, set }) => {
        try {
            const [doc] = await db.select(`documents:${id}`);
            if (!doc) {
                set.status = 404;
                return { success: false, error: "Document not found" };
            }
            return { success: true, data: doc };
        } catch (error: any) {
            logger.error(`Failed to get document ${id}`, error);
            set.status = 500;
            return { success: false, error: error.message };
        }
    });
