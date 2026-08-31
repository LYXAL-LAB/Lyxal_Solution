-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_to_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_to_schema(
    $dsl: object
) -> object {
    LET $validated = fn::validation_dsl_validate_object($dsl);

    RETURN object::from_entries(
        array::map(
            object::entries($validated.fields),
            |$entry| [
                $entry[0],
                {
                    required: $entry[1].required,
                    nullable: $entry[1].nullable,
                    type: $entry[1].type,
                    min_length: $entry[1].min_length,
                    max_length: $entry[1].max_length,
                    min: $entry[1].min,
                    max: $entry[1].max,
                    enum: $entry[1].enum
                }
            ]
        )
    );
}
COMMENT "
Transforme le DSL vers le schéma déclaratif du Validation Engine.
"
PERMISSIONS FULL;
