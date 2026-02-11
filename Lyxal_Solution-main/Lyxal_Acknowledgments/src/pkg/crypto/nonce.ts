import { randomBytes } from "crypto";

// GenerateNonce creates a 16-byte cryptographically secure random nonce for replay attack prevention
export function generateNonce(): string {
    const nonceBytes = randomBytes(16);
    // Using base64url encoding (no padding) to match Go's base64.RawURLEncoding
    return nonceBytes.toString("base64url");
}
