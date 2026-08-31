-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_schema($compiled_schema:object)->object{
 LET $fields=object::from_entries(array::map(object::entries($compiled_schema.fields),|$e|[$e[0],fn::validation_optimizer_pipeline($e[1]).optimized]));
 RETURN object::extend($compiled_schema,{fields:$fields,optimized_at:time::now()});
}
COMMENT "Optimise tous les pipelines d'un schéma."
PERMISSIONS FULL;
