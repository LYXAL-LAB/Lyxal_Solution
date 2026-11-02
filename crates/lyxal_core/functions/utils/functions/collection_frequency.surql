-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_frequency.surql
-- Fonction : fn::utils_collection_frequency
--
-- Calcule la fréquence des valeurs d'une collection.
--
-- Paramètres
--   $value : array<any>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
