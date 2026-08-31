-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_schema($compiled_schema:object)->object{
 LET $fields=object::from_entries(array::map(object::entries($compiled_schema.compiled_fields),|$e|[$e[0],object::extend($e[1],{steps:fn::sanitize_optimizer_pipeline($e[1].steps).optimized})]));
 RETURN object::extend($compiled_schema,{compiled_fields:$fields,optimized_at:time::now()});
}
COMMENT "Optimise tous les pipelines d'un schéma compilé."
PERMISSIONS FULL;
