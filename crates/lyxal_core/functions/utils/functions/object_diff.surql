-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_diff.surql
-- Fonction : fn::utils_object_diff
--
-- Calcule les différences de premier niveau entre deux objets.
--
-- Paramètres
--   $left  : object
--   $right : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_diff(
    $left: object,
    $right: object
) -> object {
    LET $keys = array::distinct(
        array::concat(
            object::keys($left),
            object::keys($right)
        )
    );

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
        changed:array::len($changes) > 0,
        changes:$changes,
        change_count:array::len($changes)
    };
}
COMMENT "Calcule les différences de premier niveau entre deux objets."
PERMISSIONS FULL;
