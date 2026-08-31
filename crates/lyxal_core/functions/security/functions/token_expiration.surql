-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_expiration
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_expiration(
    $issued_at: datetime,
    $ttl: duration,
    $now: datetime
) -> object {
    IF $ttl <= 0s {
        THROW "SECURITY_INVALID_TOKEN_TTL";
    };

    LET $expires_at = $issued_at + $ttl;

    RETURN {
        issued_at: $issued_at,
        expires_at: $expires_at,
        expired: $expires_at <= $now,
        remaining: IF $expires_at <= $now {
            0s
        } ELSE {
            $expires_at - $now
        }
    };
}
COMMENT "Calcule l'expiration et le temps restant d'un token."
PERMISSIONS FULL;
