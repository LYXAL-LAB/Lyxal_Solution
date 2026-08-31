-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_keep_keys
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_keep_keys(
    $value: object,
    $keys: array<string>
) -> object {
    RETURN fn::sanitize_remove_unknown_keys($value,$keys);
}
COMMENT "Conserve uniquement les clés demandées."
PERMISSIONS FULL;
