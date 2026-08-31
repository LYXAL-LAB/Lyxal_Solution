-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_group_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_group_by(
    $value: array<object>,
    $key: string
) -> object {
    RETURN fn::utils_array_group_by($value,$key);
}
COMMENT "Regroupe une collection d'objets selon une clé."
PERMISSIONS FULL;
