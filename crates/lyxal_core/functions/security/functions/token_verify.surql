-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_verify(
    $token_reference: string,
    $candidate: string,
    $now: datetime,
    $expires_at: datetime,
    $status: string
) -> object {
    LET $clean_status = string::lowercase(string::trim($status));

    RETURN {
        operation: "opaque_token_verify",
        token_reference: string::trim($token_reference),
        candidate: $candidate,
        expired: $expires_at <= $now,
        active: $clean_status = "active",
        requires_native_crypto: true,
        constant_time_required: true
    };
}
COMMENT "
Prépare la vérification constante en temps d'un token opaque par le moteur Rust.
"
PERMISSIONS FULL;
