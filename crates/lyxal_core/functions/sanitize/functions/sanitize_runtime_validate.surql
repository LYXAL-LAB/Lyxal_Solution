-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_validate(
    $schema: object,
    $payload: object,
    $max_steps: int,
    $request_id: option<string>
) -> object {
    LET $context = fn::sanitize_runtime_context(
        $schema.name,
        $schema.version,
        "strict",
        {}
    );
    LET $request = fn::sanitize_runtime_request(
        $context,
        $payload,
        $request_id,
        {}
    );
    LET $compiled = fn::sanitize_schema_compile($schema,$max_steps);
    LET $output = fn::sanitize_runtime_execute_object(
        $compiled,
        $payload,
        $max_steps
    );
    RETURN fn::sanitize_runtime_response(
        $request,
        $output,
        time::now()
    );
}
COMMENT "Exécute le cycle complet de sanitation d'un objet."
PERMISSIONS FULL;
