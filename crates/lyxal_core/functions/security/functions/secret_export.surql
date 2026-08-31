-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_export
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_export(
    $secret_reference: string,
    $purpose: string,
    $expires_at: datetime
) -> object {
    RETURN {
        operation: "secret_export",
        secret_reference: string::trim($secret_reference),
        purpose: string::trim($purpose),
        expires_at: $expires_at,
        requires_native_vault: true,
        plaintext_export_forbidden: true
    };
}
COMMENT "Prépare une exportation contrôlée par référence via le coffre Rust."
PERMISSIONS FULL;
