import { db } from "../db";
import { logger } from "../pkg/logger";

export interface DocumentAgg {
    docId: string;
    count: number;           // Total signatures
    expectedCount: number;   // Expected signers
    signedCount: number;     // Expected signers who signed
    unexpectedCount: number; // Unexpected signatures
}

export interface ChainIntegrityResult {
    isValid: boolean;
    totalSigs: number;
    validSigs: number;
    invalidSigs: number;
    errors: string[];
    docId: string;
}

export class AdminRepository {
    /**
     * List all documents with aggregated signature metrics for admin dashboard
     */
    async listDocumentsWithCounts(): Promise<DocumentAgg[]> {
        try {
            // Complex aggregation query in SurrealQL
            const query = `
        LET $all_docs = (
          SELECT VALUE doc_id FROM signatures GROUP ALL
          UNION
          SELECT VALUE doc_id FROM expected_signers GROUP ALL
          UNION
          SELECT VALUE doc_id FROM documents GROUP ALL
        );
        
        FOR $doc_id IN $all_docs {
          LET $sig_count = (SELECT count() FROM signatures WHERE doc_id = $doc_id GROUP ALL)[0].count ?? 0;
          LET $expected_count = (SELECT count() FROM expected_signers WHERE doc_id = $doc_id GROUP ALL)[0].count ?? 0;
          LET $signed_count = (
            SELECT count() FROM (
              SELECT es.doc_id FROM expected_signers es
              WHERE es.doc_id = $doc_id
              AND es.email IN (SELECT VALUE user_email FROM signatures WHERE doc_id = $doc_id)
            ) GROUP ALL
          )[0].count ?? 0;
          
          RETURN {
            docId: $doc_id,
            count: $sig_count,
            expectedCount: $expected_count,
            signedCount: $signed_count,
            unexpectedCount: $sig_count - $signed_count
          };
        };
      `;

            const result = await db.query(query);
            return result[0] as DocumentAgg[];
        } catch (error) {
            logger.error("Failed to list documents with counts", error);
            throw error;
        }
    }

    /**
     * List all signatures for a document in reverse chronological order
     */
    async listSignaturesByDoc(docId: string): Promise<any[]> {
        try {
            const result = await db.query(
                "SELECT * FROM signatures WHERE doc_id = $docId ORDER BY created_at DESC",
                { docId }
            );
            return result[0] as any[];
        } catch (error) {
            logger.error(`Failed to list signatures for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Verify cryptographic hash chain integrity for all signatures in a document
     */
    async verifyDocumentChainIntegrity(docId: string): Promise<ChainIntegrityResult> {
        try {
            const signatures = await this.listSignaturesByDoc(docId);
            return this.verifyChainIntegrity(signatures, docId);
        } catch (error) {
            logger.error(`Failed to verify chain integrity for doc ${docId}`, error);
            throw error;
        }
    }

    /**
     * Internal method to verify signature chain integrity
     */
    private verifyChainIntegrity(signatures: any[], docId: string): ChainIntegrityResult {
        const result: ChainIntegrityResult = {
            isValid: true,
            totalSigs: signatures.length,
            validSigs: 0,
            invalidSigs: 0,
            errors: [],
            docId
        };

        if (signatures.length === 0) {
            return result;
        }

        // Sort by ID (chronological order)
        const sorted = [...signatures].sort((a, b) => {
            const idA = parseInt(a.id.split(':')[1]);
            const idB = parseInt(b.id.split(':')[1]);
            return idA - idB;
        });

        // Verify first signature (genesis)
        const first = sorted[0];
        if (first.prev_hash) {
            result.isValid = false;
            result.invalidSigs++;
            result.errors.push(`Genesis signature ${first.id} has prev_hash (should be null)`);
        } else {
            result.validSigs++;
        }

        // Verify subsequent signatures
        for (let i = 1; i < sorted.length; i++) {
            const current = sorted[i];
            const previous = sorted[i - 1];

            // Compute expected prev_hash from previous signature
            // This should match the logic in signature.go's ComputeRecordHash()
            const expectedPrevHash = this.computeRecordHash(previous);

            if (!current.prev_hash) {
                result.isValid = false;
                result.invalidSigs++;
                result.errors.push(`Signature ${current.id} missing prev_hash`);
            } else if (current.prev_hash !== expectedPrevHash) {
                result.isValid = false;
                result.invalidSigs++;
                result.errors.push(
                    `Signature ${current.id} has invalid prev_hash: expected ${expectedPrevHash.substring(0, 12)}..., got ${current.prev_hash.substring(0, 12)}...`
                );
            } else {
                result.validSigs++;
            }
        }

        return result;
    }

    /**
     * Compute SHA-256 hash of signature record for chain validation
     */
    private computeRecordHash(signature: any): string {
        // Reproduce the Go logic from signature.go's ComputeRecordHash()
        const canonical = `${signature.id}|${signature.doc_id}|${signature.user_email}|${signature.signed_at}|${signature.payload_hash}`;

        // Use Bun's built-in crypto for SHA-256
        const hash = new Bun.CryptoHasher("sha256");
        hash.update(canonical);
        return hash.digest("hex");
    }
}

export const adminRepository = new AdminRepository();
