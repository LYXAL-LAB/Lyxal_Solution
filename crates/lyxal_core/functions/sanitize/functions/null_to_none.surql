-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_null_to_none
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_null_to_none(
    $value: object
) -> object {
    RETURN object::from_entries(
        array::map(
            object::entries($value),
            |$entry| [
                $entry[0],
                IF type::is_null($entry[1]) { NONE } ELSE { $entry[1] }
            ]
        )
    );
}
COMMENT "Convertit les valeurs NULL en NONE dans un objet de premier niveau."
PERMISSIONS FULL;
