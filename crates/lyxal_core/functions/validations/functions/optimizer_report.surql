-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_report($compiled_schema:object,$optimized_schema:object)->object{
 LET $fields=object::keys($compiled_schema.fields);
 RETURN {schema_name:$compiled_schema.name,schema_version:$compiled_schema.version,fields:array::map($fields,|$f|{field:$f,original_steps:array::len($compiled_schema.fields[$f]),optimized_steps:array::len($optimized_schema.fields[$f]),original_cost:fn::validation_optimizer_pipeline_cost($compiled_schema.fields[$f]),optimized_cost:fn::validation_optimizer_pipeline_cost($optimized_schema.fields[$f])}),generated_at:time::now()};
}
COMMENT "Produit un rapport d'optimisation."
PERMISSIONS FULL;
