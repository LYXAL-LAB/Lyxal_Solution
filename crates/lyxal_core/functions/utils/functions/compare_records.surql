-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/compare_records.surql
-- Fonction : fn::utils_compare_records
--
-- Compare deux records sur une liste de clés.
--
-- Paramètres
--   $left  : object
--   $right : object
--   $keys  : array<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_compare_records(
    $left: object,
    $right: object,
    $keys: array<string>
) -> object {
    LET $changes = array::filter(
        array::map(
            $keys,
            |$key| {
                key:$key,
                left:$left[$key],
                right:$right[$key],
                changed:$left[$key] != $right[$key]
            }
        ),
        |$change| $change.changed
    );

    RETURN {
        equal:array::len($changes)=0,
        changes:$changes,
        change_count:array::len($changes)
    };
}
COMMENT "Compare deux records sur une liste de clés."
PERMISSIONS FULL;
