-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_pipeline($pipeline:array<object>)->object{
 LET $valid=fn::validation_optimizer_validate_pipeline($pipeline);
 LET $dedup=fn::validation_optimizer_remove_duplicate_steps($valid);
 LET $merged=fn::validation_optimizer_merge_length_steps($dedup);
 LET $ordered=fn::validation_optimizer_order_pipeline($merged);
 LET $optimized=fn::validation_optimizer_strip_internal($ordered);
 RETURN {original:$pipeline,optimized:$optimized,original_count:array::len($pipeline),optimized_count:array::len($optimized),original_cost:fn::validation_optimizer_pipeline_cost($pipeline),optimized_cost:fn::validation_optimizer_pipeline_cost($optimized)};
}
COMMENT "Optimise un pipeline complet."
PERMISSIONS FULL;
