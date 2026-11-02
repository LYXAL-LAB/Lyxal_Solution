-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_merge_deep.surql
-- Fonction : fn::utils_object_merge_deep
--
-- Fusionne récursivement deux objets.
--
-- Paramètres
--   $base     : object
--   $override : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_merge_deep(
    $base: object,
    $override: object
) -> object {
    RETURN object::from_entries(
        array::map(
            array::distinct(
                array::concat(
                    object::keys($base),
                    object::keys($override)
                )
            ),
            |$key| [
                $key,
                IF type::is_object($base[$key])
                    AND type::is_object($override[$key])
                {
                    fn::utils_object_merge_deep(
                        $base[$key],
                        $override[$key]
                    )
                } ELSE IF $override[$key] IS NOT NONE {
                    $override[$key]
                } ELSE {
                    $base[$key]
                }
            ]
        )
    );
}
COMMENT "Fusionne récursivement deux objets."
PERMISSIONS FULL;
