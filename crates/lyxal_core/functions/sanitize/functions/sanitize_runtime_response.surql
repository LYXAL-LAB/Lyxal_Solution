-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_response
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_response(
    $request: object,
    $output: any,
    $completed_at: datetime
) -> object {
    RETURN {
        request_id:$request.request_id,
        schema_name:$request.context.schema_name,
        schema_version:$request.context.schema_version,
        mode:$request.context.mode,
        input:$request.payload,
        output:$output,
        changed:$request.payload != $output,
        started_at:$request.context.started_at,
        completed_at:$completed_at
    };
}
COMMENT "Construit la réponse publique du runtime."
PERMISSIONS FULL;
