-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_defaults
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_object_defaults(
    $value: object,
    $defaults: object
) -> object {
    RETURN object::from_entries(
        array::map(
            array::distinct(
                array::concat(
                    object::keys($defaults),
                    object::keys($value)
                )
            ),
            |$key| [
                $key,
                IF $value[$key] IS NONE {
                    $defaults[$key]
                } ELSE {
                    $value[$key]
                }
            ]
        )
    );
}
COMMENT "Applique des valeurs par défaut aux clés absentes."
PERMISSIONS FULL;
