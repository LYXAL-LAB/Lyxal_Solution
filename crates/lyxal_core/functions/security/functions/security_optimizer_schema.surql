-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_schema(
    $compiled_schema: object
) -> object {
    LET $fields = object::from_entries(
        array::map(
            object::entries($compiled_schema.compiled_fields),
            |$entry| [
                $entry[0],
                object::extend(
                    $entry[1],
                    {
                        steps:fn::security_optimizer_pipeline(
                            $entry[1].steps
                        ).optimized
                    }
                )
            ]
        )
    );

    RETURN object::extend(
        $compiled_schema,
        {
            compiled_fields:$fields,
            optimized_at:time::now()
        }
    );
}
COMMENT "Optimise tous les pipelines d'un schéma Security."
PERMISSIONS FULL;
