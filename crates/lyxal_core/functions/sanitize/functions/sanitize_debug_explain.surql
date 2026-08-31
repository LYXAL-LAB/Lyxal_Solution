-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_explain
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_explain($trace:object)->object{
 RETURN {field:$trace.field,rule:$trace.rule,changed:$trace.changed,input_type:IF $trace.input IS NONE{"none"}ELSE{type::of($trace.input)},output_type:IF $trace.output IS NONE{"none"}ELSE{type::of($trace.output)},explanation:string::concat("La règle ",$trace.rule,IF $trace.changed{" a transformé "}ELSE{" n'a pas transformé "},"le champ ",$trace.field,".")};
}
COMMENT "Explique une trace de sanitation."
PERMISSIONS FULL;
