-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_group_by.surql
-- Fonction : fn::utils_array_group_by
--
-- Regroupe un tableau d'objets selon une clé de premier niveau.
--
-- Paramètres
--   $value : array<object>
--   $key   : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_group_by(
    $value: array<object>,
    $key: string
) -> object {
    LET $groups = array::distinct(
        array::map($value, |$item| <string>$item[$key])
    );

    RETURN object::from_entries(
        array::map(
            $groups,
            |$group| [
                $group,
                array::filter(
                    $value,
                    |$item| <string>$item[$key] = $group
                )
            ]
        )
    );
}
COMMENT "Regroupe un tableau d'objets selon une clé de premier niveau."
PERMISSIONS FULL;
