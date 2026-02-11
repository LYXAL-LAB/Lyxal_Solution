import { Elysia, t } from "elysia";
import { Ed25519Signer } from "../pkg/crypto";
import { db } from "../db";
import { logger } from "../pkg/logger";
import { webhookService } from "../services/webhook.service";
import { config } from "../config";

// Initialize signer with private key from config
const privateKey = process.env.ACKIFY_PRIVATE_KEY; // Keep this for now as it's crypto-specific
const signer = new Ed25519Signer(privateKey);

export const signatureController = new Elysia({ prefix: "/signatures" })
    .post("/", async ({ body, set }) => {
        const { doc_id, user } = body;

        try {
            // 1. Generate Nonce and Timestamp
            const nonce = crypto.randomUUID().replace(/-/g, "").substring(0, 16);
            const timestamp = new Date();

            // 2. Sign the payload (Hybrid approach: Crypto in API)
            const { payloadHash, signature } = signer.createSignature(
                doc_id,
                user,
                timestamp,
                nonce
            );

            logger.info(`Generated signature for doc ${doc_id} by user ${user.email}`);

            // 3. Call SurrealDB function to register (Atomic chaining)
            const result = await db.query(
                `RETURN fn::register_signature($doc_id, $user_sub, $user_email, $user_name, $signature, $payload_hash, $nonce, $doc_checksum, $referer)`,
                {
                    doc_id,
                    user_sub: user.sub,
                    user_email: user.email,
                    user_name: user.name || "",
                    signature,
                    payload_hash: payloadHash,
                    nonce,
                    doc_checksum: "",
                    referer: "api"
                }
            );

            // 4. Publish Webhook Event
            webhookService.publish("signature.created", {
                signature_id: (result[0] as any).id,
                doc_id,
                user_email: user.email,
                signed_at: timestamp
            });

            return { success: true, data: result[0] };

        } catch (error: any) {
            logger.error("Signature registration failed", error);
            set.status = 400;
            return { success: false, error: error.message };
        }
    }, {
        body: t.Object({
            doc_id: t.String(),
            user: t.Object({
                sub: t.String(),
                email: t.String(),
                name: t.Optional(t.String())
            })
        })
    });
