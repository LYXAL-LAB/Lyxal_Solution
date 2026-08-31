-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_pipeline($pipeline:array<object>)->object{
 LET $validated=fn::sanitize_optimizer_validate($pipeline);
 LET $dedup=fn::sanitize_optimizer_remove_duplicates($validated);
 LET $ordered=fn::sanitize_optimizer_order($dedup);
 LET $clean=array::map($ordered,|$s|object::from_entries(array::filter(object::entries($s),|$e|!string::starts_with($e[0],"_"))));
 RETURN {original:$pipeline,optimized:$clean,original_count:array::len($pipeline),optimized_count:array::len($clean),original_cost:fn::sanitize_optimizer_cost($pipeline),optimized_cost:fn::sanitize_optimizer_cost($clean)};
}
COMMENT "Optimise un pipeline complet."
PERMISSIONS FULL;
