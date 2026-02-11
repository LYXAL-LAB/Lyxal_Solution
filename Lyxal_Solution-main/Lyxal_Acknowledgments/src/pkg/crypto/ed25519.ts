import * as nacl from 'tweetnacl';
import * as naclUtil from 'tweetnacl-util';

// Interface for User model subset needed for signing
export interface SignerUser {
  sub: string;
  email: string;
  name?: string;
}

export class Ed25519Signer {
  private keyPair: nacl.SignKeyPair;

  constructor(privateKeyBase64?: string) {
    if (privateKeyBase64) {
      try {
        const secretKey = naclUtil.decodeBase64(privateKeyBase64);
        this.keyPair = nacl.sign.keyPair.fromSecretKey(secretKey);
      } catch (e) {
        throw new Error(`Invalid private key: ${e}`);
      }
    } else {
      // Ephemeral key for development/testing
      this.keyPair = nacl.sign.keyPair();
      console.warn('[WARN] Generated ephemeral Ed25519 keypair. Set ACKIFY_PRIVATE_KEY to persist.');
    }
  }

  /**
   * Creates a canonical payload and signs it using Ed25519.
   * Returns [payloadHashBase64, signatureBase64]
   */
  public createSignature(
    docId: string,
    user: SignerUser,
    timestamp: Date,
    nonce: string,
    docChecksum: string = ''
  ): { payloadHash: string; signature: string } {
    const payload = this.canonicalPayload(docId, user, timestamp, nonce, docChecksum);
    
    // Hash payload with SHA-256 (using Bun's native crypto or Web Crypto API)
    const hasher = new Bun.CryptoHasher("sha256");
    hasher.update(payload);
    const hash = hasher.digest(); // Uint8Array

    // Sign the hash
    const signature = nacl.sign.detached(hash, this.keyPair.secretKey);

    return {
      payloadHash: naclUtil.encodeBase64(hash),
      signature: naclUtil.encodeBase64(signature)
    };
  }

  public getPublicKey(): string {
    return naclUtil.encodeBase64(this.keyPair.publicKey);
  }

  /**
   * Constructs the exact string to be signed.
   * MUST MATCH Go implementation exactly for verification compatibility.
   */
  private canonicalPayload(
    docId: string,
    user: SignerUser,
    timestamp: Date,
    nonce: string,
    docChecksum: string
  ): Uint8Array {
    // Format: "doc_id=...\nuser_sub=...\nuser_email=...\nsigned_at=...\nnonce=...\n"
    // Note: Go's time.RFC3339Nano format is used. JS toISOString() is close but needs checking.
    // We use toISOString() which is ISO 8601. Go's RFC3339Nano might have more precision or different timezone handling (Z).
    // Ideally we should ensure strict format matching.
    
    const normalizedEmail = user.email.trim().toLowerCase();
    const timeStr = timestamp.toISOString(); // e.g. "2023-10-27T10:00:00.000Z"

    let payloadStr = `doc_id=${docId}\n` +
                     `user_sub=${user.sub}\n` +
                     `user_email=${normalizedEmail}\n` +
                     `signed_at=${timeStr}\n` +
                     `nonce=${nonce}\n`;

    if (docChecksum) {
      payloadStr += `doc_checksum=${docChecksum}\n`;
    }

    return naclUtil.decodeUTF8(payloadStr);
  }
}
