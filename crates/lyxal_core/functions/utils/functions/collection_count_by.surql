-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_count_by.surql
-- Fonction : fn::utils_collection_count_by
--
-- Compte les éléments d'une collection par valeur de clé.
--
-- Paramètres
--   $value : array<object>
--   $key   : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_collection_count_by(
    $value: array<object>,
    $key: string
) -> object {
    LET $groups = fn::utils_array_group_by($value,$key);

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
