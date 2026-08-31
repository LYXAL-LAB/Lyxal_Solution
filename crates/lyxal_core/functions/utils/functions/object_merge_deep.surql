-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_merge_deep
-- Version  : 1.0.0
-- Statut   : Stable
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
