-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_execute_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_execute_field(
 $compiled_schema:object,$field:string,$value:option<any>,$max_steps:int
) -> object {
 LET $result=fn::validation_compiled_execute_field($compiled_schema,$field,$value,$max_steps);
 RETURN {field:$field,valid:true,value:$result,errors:[],warnings:[]};
}
COMMENT "Exécute un champ compilé."
PERMISSIONS FULL;
