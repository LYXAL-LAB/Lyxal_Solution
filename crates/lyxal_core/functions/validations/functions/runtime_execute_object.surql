-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_execute_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_execute_object(
 $compiled_schema:object,$payload:object,$max_steps:int
) -> object {
 LET $validated=fn::validation_compiled_execute_object($compiled_schema,$payload,$max_steps);
 RETURN {valid:true,value:$validated,errors:[],warnings:[]};
}
COMMENT "Exécute un schéma compilé sur un objet."
PERMISSIONS FULL;
