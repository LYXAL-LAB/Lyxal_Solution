-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_group_by
-- Version  : 1.0.0
-- Statut   : Stable
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
