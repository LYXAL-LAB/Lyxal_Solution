import { randomBytes, createHash } from "crypto";

// PKCE code verifier length (RFC 7636 recommends 43-128 characters)
const CODE_VERIFIER_LENGTH = 43;

// Regex to validate code verifier format (RFC 7636)
const CODE_VERIFIER_REGEX = /^[A-Za-z0-9\-._~]{43,128}$/;

// GenerateCodeVerifier generates a cryptographically secure PKCE code verifier
// The verifier is a random string of 43-128 characters using the unreserved character set.
// Returns a base64 URL-safe encoded string suitable for OAuth2 PKCE flow.
export function generateCodeVerifier(): string {
    // Generate random bytes (32 bytes = 43 characters in base64)
    const random = randomBytes(32);

    // Encode to base64 URL-safe (no padding)
    const verifier = random.toString("base64url");

    if (!validateCodeVerifier(verifier)) {
        throw new Error("generated verifier failed validation");
    }

    return verifier;
}

// GenerateCodeChallenge generates a PKCE code challenge from a code verifier
// Uses the S256 method: BASE64URL(SHA256(ASCII(code_verifier)))
export function generateCodeChallenge(verifier: string): string {
    const hash = createHash("sha256").update(verifier).digest();
    return hash.toString("base64url");
}

// ValidateCodeVerifier validates that a code verifier meets RFC 7636 requirements
// - Length: 43-128 characters
// - Characters: [A-Za-z0-9-._~]
export function validateCodeVerifier(verifier: string): boolean {
    return CODE_VERIFIER_REGEX.test(verifier);
}
