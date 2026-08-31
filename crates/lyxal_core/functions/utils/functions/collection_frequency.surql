-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_frequency
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_frequency(
    $value: array<any>
) -> object {
    LET $unique = array::distinct($value);

    RETURN object::from_entries(
        array::map(
            $unique,
            |$item|[
                <string>$item,
                array::len(
                    array::filter(
                        $value,
                        |$current|$current=$item
                    )
                )
            ]
        )
    );
}
COMMENT "Calcule la fréquence des valeurs d'une collection."
PERMISSIONS FULL;
