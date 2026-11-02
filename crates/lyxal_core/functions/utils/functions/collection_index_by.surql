-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_index_by.surql
-- Fonction : fn::utils_collection_index_by
--
-- Indexe une collection d'objets par une clé.
--
-- Paramètres
--   $value : array<object>
--   $key   : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
