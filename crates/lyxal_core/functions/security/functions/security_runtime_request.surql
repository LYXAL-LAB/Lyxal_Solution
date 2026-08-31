-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_request(
    $context:object,
    $payload:any,
    $request_id:option<string>,
    $metadata:option<object>
)->object{
 LET $id=IF $request_id IS NONE{<string>rand::uuid::v7()}ELSE{string::trim($request_id)};
 RETURN {
  request_id:$id,
  context:$context,
  payload:$payload,
  metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
 };
}
COMMENT "Construit une requête Security Runtime."
PERMISSIONS FULL;
