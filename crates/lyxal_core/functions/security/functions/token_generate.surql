-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_generate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_generate(
    $prefix: string,
    $length: int,
    $issued_at: datetime,
    $ttl: duration
) -> object {
    IF $length < 24 OR $length > 256 {
        THROW "SECURITY_INVALID_TOKEN_LENGTH";
    };
    IF $ttl <= 0s {
        THROW "SECURITY_INVALID_TOKEN_TTL";
    };

    LET $clean_prefix = string::lowercase(string::trim($prefix));
    LET $token_id = rand::uuid::v7();
    LET $secret = rand::id($length);

    RETURN {
        token_id: $token_id,
        token: IF $clean_prefix = "" {
            $secret
        } ELSE {
            string::concat($clean_prefix, "_", $secret)
        },
        issued_at: $issued_at,
        expires_at: $issued_at + $ttl,
        status: "active"
    };
}
COMMENT "
Génère un token opaque textuel avec UUID v7, date d'émission et expiration.
"
PERMISSIONS FULL;
