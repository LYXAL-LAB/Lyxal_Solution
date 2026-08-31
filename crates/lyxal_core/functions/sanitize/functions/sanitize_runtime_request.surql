-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_request(
    $context: object,
    $payload: any,
    $request_id: option<string>,
    $metadata: option<object>
) -> object {
    LET $id = IF $request_id IS NONE {
        string::concat($context.schema_name,":",time::format(time::now(),"%Y%m%d%H%M%S"))
    } ELSE {
        string::trim($request_id)
    };
    IF $id = "" { THROW "SANITIZE_RUNTIME_INVALID_REQUEST_ID"; };
    RETURN {
        request_id:$id,
        context:$context,
        payload:$payload,
        metadata:IF $metadata IS NONE {{} } ELSE {$metadata}
    };
}
COMMENT "Construit une requête runtime normalisée."
PERMISSIONS FULL;
