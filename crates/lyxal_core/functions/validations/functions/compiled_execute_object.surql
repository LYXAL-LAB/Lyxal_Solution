-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_execute_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_execute_object(
    $compiled_schema: object,
    $value: object,
    $max_steps: int
) -> object {
    RETURN object::from_entries(
        array::map(
            object::keys($compiled_schema.fields),
            |$field| [
                $field,
                fn::validation_compiled_execute_field(
                    $compiled_schema,
                    $field,
                    $value[$field],
                    $max_steps
                )
            ]
        )
    );
}
COMMENT "Exécute tous les pipelines d'un schéma compilé."
PERMISSIONS FULL;
