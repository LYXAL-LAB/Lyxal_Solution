-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_batch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_batch(
    $compiled_schema: object,
    $payloads: array<object>,
    $max_steps: int
) -> object {
    LET $results = array::map(
        $payloads,
        |$payload| fn::sanitize_runtime_execute_object(
            $compiled_schema,
            $payload,
            $max_steps
        )
    );
    RETURN {total:array::len($results),results:$results};
}
COMMENT "Exécute un schéma compilé sur un lot d'objets."
PERMISSIONS FULL;
