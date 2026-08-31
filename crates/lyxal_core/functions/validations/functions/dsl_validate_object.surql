-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_validate_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_validate_object(
    $dsl: object
) -> object {
    IF $dsl.name IS NONE
        OR $dsl.version IS NONE
        OR $dsl.fields IS NONE
    {
        THROW "VALIDATION_DSL_INVALID_OBJECT";
    };

    RETURN object::extend(
        $dsl,
        {
            fields: object::from_entries(
                array::map(
                    object::entries($dsl.fields),
                    |$entry| [
                        $entry[0],
                        fn::validation_dsl_validate_field(
                            $entry[0],
                            $entry[1]
                        ).definition
                    ]
                )
            )
        }
    );
}
COMMENT "
Valide toutes les définitions de champs d'un objet DSL.
"
PERMISSIONS FULL;
