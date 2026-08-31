-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_decode_uri
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_decode_uri(
    $value: string
) -> string {
    RETURN encoding::url::decode($value);
}
COMMENT "Décode une chaîne URI encodée."
PERMISSIONS FULL;
