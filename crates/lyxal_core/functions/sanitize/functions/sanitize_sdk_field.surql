-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_field($pipeline:array<object>,$field:string,$value:option<any>,$options:option<object>)->object{
 LET $max=IF $options IS NONE OR $options.max_steps IS NONE{50}ELSE{$options.max_steps};
 LET $output=fn::sanitize_pipeline_execute($value,$field,$pipeline,$max);
 RETURN {field:$field,input:$value,output:$output,changed:$value!=$output};
}
COMMENT "Sanitise un champ via l'API publique."
PERMISSIONS FULL;
