-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_default_values
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_default_values(
    $value: object,
    $defaults: object
) -> object {
    RETURN object::from_entries(
        array::map(
            object::entries($defaults),
            |$entry| [
                $entry[0],
                IF $value[$entry[0]] IS NONE {
                    $entry[1]
                } ELSE {
                    $value[$entry[0]]
                }
            ]
        )
    ) + $value;
}
COMMENT "Applique des valeurs par défaut aux clés absentes."
PERMISSIONS FULL;
