-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_partition.surql
-- Fonction : fn::utils_array_partition
--
-- Sépare un tableau d'objets selon une valeur de clé.
--
-- Paramètres
--   $value    : array<object>
--   $key      : string
--   $expected : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_partition(
    $value: array<object>,
    $key: string,
    $expected: any
) -> object {
    RETURN {
        matched: array::filter(
            $value,
            |$item| $item[$key] = $expected
        ),
        unmatched: array::filter(
            $value,
            |$item| $item[$key] != $expected
        )
    };
}
COMMENT "Sépare un tableau d'objets selon une valeur de clé."
PERMISSIONS FULL;
