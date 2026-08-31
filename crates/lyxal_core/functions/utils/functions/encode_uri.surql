-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_encode_uri
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_encode_uri(
    $value: string
) -> string {
    RETURN encoding::url::encode($value);
}
COMMENT "Encode une chaîne pour une URI."
PERMISSIONS FULL;
