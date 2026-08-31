-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_to_json
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_to_json(
    $value: any
) -> string {
    RETURN encoding::json::encode($value);
}
COMMENT "Encode une valeur en JSON."
PERMISSIONS FULL;
