-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_index_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_index_by(
    $value: array<object>,
    $key: string
) -> object {
    RETURN object::from_entries(
        array::map(
            $value,
            |$item|[
                <string>$item[$key],
                $item
            ]
        )
    );
}
COMMENT "Indexe une collection d'objets par une clé."
PERMISSIONS FULL;
