-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_count_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_count_by(
    $value: array<object>,
    $key: string
) -> object {
    LET $groups = fn::utils_collection_group_by($value,$key);

    RETURN object::from_entries(
        array::map(
            object::entries($groups),
            |$entry|[
                $entry[0],
                array::len($entry[1])
            ]
        )
    );
}
COMMENT "Compte les éléments d'une collection par valeur de clé."
PERMISSIONS FULL;
