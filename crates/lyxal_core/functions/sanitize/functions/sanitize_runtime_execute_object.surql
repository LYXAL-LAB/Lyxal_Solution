-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_execute_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_execute_object(
    $compiled_schema: object,
    $payload: object,
    $max_steps: int
) -> object {
    LET $field_names = object::keys($compiled_schema.compiled_fields);
    LET $sanitized = object::from_entries(
        array::map(
            $field_names,
            |$field| [
                $field,
                fn::sanitize_runtime_execute_field(
                    $compiled_schema.compiled_fields[$field],
                    IF $payload[$field] IS NONE
                       AND $compiled_schema.fields[$field].default IS NOT NONE
                    {
                        $compiled_schema.fields[$field].default
                    } ELSE {
                        $payload[$field]
                    },
                    $max_steps
                ).output
            ]
        )
    );
    RETURN IF $compiled_schema.unknown_keys_policy = "allow" {
        object::extend($payload,$sanitized)
    } ELSE {
        $sanitized
    };
}
COMMENT "Exécute un schéma compilé sur un objet."
PERMISSIONS FULL;
