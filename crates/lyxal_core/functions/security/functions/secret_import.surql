-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_import
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_import(
    $target_reference: string,
    $secret: string,
    $metadata: option<object>
) -> object {
    RETURN {
        operation: "secret_import",
        target_reference: string::trim($target_reference),
        secret: $secret,
        metadata: IF $metadata IS NONE { {} } ELSE { $metadata },
        requires_native_vault: true,
        persist_plaintext: false
    };
}
COMMENT "Prépare l'import d'un secret dans le coffre natif."
PERMISSIONS FULL;
