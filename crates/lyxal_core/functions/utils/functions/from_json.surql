-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_from_json
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_from_json(
    $value: string
) -> any {
    RETURN encoding::json::decode($value);
}
COMMENT "Décode une chaîne JSON."
PERMISSIONS FULL;
