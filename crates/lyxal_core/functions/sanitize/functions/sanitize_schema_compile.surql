-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema_compile(
    $schema: object,
    $max_steps: int
) -> object {
    LET $compiled_fields = object::from_entries(
        array::map(
            object::entries($schema.fields),
            |$entry| [
                $entry[0],
                fn::sanitize_pipeline_compile(
                    IF $entry[1].pipeline IS NONE { [] } ELSE { $entry[1].pipeline },
                    string::uppercase($entry[0]),
                    $max_steps
                )
            ]
        )
    );
    RETURN object::extend($schema,{
        compiled_fields:$compiled_fields,
        compiled_at:time::now()
    });
}
COMMENT "Compile tous les pipelines d'un schéma."
PERMISSIONS FULL;
