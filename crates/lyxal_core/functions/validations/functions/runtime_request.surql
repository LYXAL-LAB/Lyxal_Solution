-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_request(
 $context:object,$payload:any,$request_id:option<string>,$metadata:option<object>
) -> object {
 LET $id=IF $request_id IS NONE{string::concat($context.schema_name,":",time::format(time::now(),"%Y%m%d%H%M%S"))}ELSE{string::trim($request_id)};
 IF $id=""{THROW "VALIDATION_RUNTIME_INVALID_REQUEST_ID";};
 RETURN {request_id:$id,context:$context,payload:$payload,metadata:IF $metadata IS NONE{{}}ELSE{$metadata}};
}
COMMENT "Construit une requête normalisée pour le Validation Runtime."
PERMISSIONS FULL;
