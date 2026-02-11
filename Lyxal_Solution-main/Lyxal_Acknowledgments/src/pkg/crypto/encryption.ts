import { randomBytes, createCipheriv, createDecipheriv } from "crypto";

// EncryptToken encrypts a plaintext token using AES-256-GCM
// The key must be 32 bytes for AES-256
// Returns: nonce + ciphertext + auth tag (combined)
export function encryptToken(plaintext: string, key: Buffer): Buffer {
    if (key.length !== 32) {
        throw new Error(`encryption key must be 32 bytes for AES-256, got ${key.length} bytes`);
    }

    if (!plaintext) {
        throw new Error("cannot encrypt empty plaintext");
    }

    const nonce = randomBytes(12); // GCM standard nonce size
    const cipher = createCipheriv("aes-256-gcm", key, nonce);

    const encrypted = Buffer.concat([cipher.update(plaintext, "utf8"), cipher.final()]);
    const tag = cipher.getAuthTag();

    // Combine nonce + ciphertext + tag
    return Buffer.concat([nonce, encrypted, tag]);
}

// DecryptToken decrypts a ciphertext using AES-256-GCM
// The key must be 32 bytes for AES-256
// Expects input format: nonce + ciphertext + auth tag (as created by EncryptToken)
export function decryptToken(ciphertext: Buffer, key: Buffer): string {
    if (key.length !== 32) {
        throw new Error(`decryption key must be 32 bytes for AES-256, got ${key.length} bytes`);
    }

    if (ciphertext.length === 0) {
        throw new Error("cannot decrypt empty ciphertext");
    }

    const nonceSize = 12;
    if (ciphertext.length < nonceSize + 16) { // 16 bytes for tag
        throw new Error(`ciphertext too short`);
    }

    const nonce = ciphertext.subarray(0, nonceSize);
    const tag = ciphertext.subarray(ciphertext.length - 16);
    const encrypted = ciphertext.subarray(nonceSize, ciphertext.length - 16);

    const decipher = createDecipheriv("aes-256-gcm", key, nonce);
    decipher.setAuthTag(tag);

    return decipher.update(encrypted, undefined, "utf8") + decipher.final("utf8");
}
