-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_validate(
 $schema_entry:object,$payload:object,$cache_entries:array<object>,$source_hash:string,$ttl:duration,$max_steps:int,$request_id:option<string>
) -> object {
 LET $context=fn::validation_runtime_context($schema_entry.name,$schema_entry.version,"fail_fast",{});
 LET $request=fn::validation_runtime_request($context,$payload,$request_id,{});
 LET $prepared=fn::validation_runtime_prepare_schema($schema_entry,$cache_entries,$source_hash,$ttl,time::now());
 LET $execution=fn::validation_runtime_execute_object($prepared.compiled_schema,$payload,$max_steps);
 RETURN object::extend(fn::validation_runtime_response($request,$execution,$prepared.cache_hit,time::now()),{cache_entry:$prepared.cache_entry});
}
COMMENT "Exécute le cycle complet de validation runtime."
PERMISSIONS FULL;
