-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_explain_failure
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_explain_failure($trace:object)->object{
 RETURN IF $trace.success=true{{failed:false,explanation:"La règle a réussi."}}ELSE{{failed:true,field:$trace.field,rule:$trace.rule,error_code:$trace.error_code,input_type:IF $trace.input IS NONE{"none"}ELSE{type::of($trace.input)},explanation:string::concat("La règle ",$trace.rule," a échoué sur le champ ",$trace.field,".")}};
}
COMMENT "Explique une trace échouée."
PERMISSIONS FULL;
