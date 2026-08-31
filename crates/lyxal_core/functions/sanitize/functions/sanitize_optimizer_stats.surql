-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_stats($compiled_schema:object)->object{
 LET $fields=object::entries($compiled_schema.compiled_fields);
 RETURN {field_count:array::len($fields),step_count:array::fold($fields,0,|$n,$e|$n+array::len($e[1].steps)),total_cost:array::fold($fields,0,|$n,$e|$n+fn::sanitize_optimizer_cost($e[1].steps))};
}
COMMENT "Calcule les statistiques d'un schéma optimisé."
PERMISSIONS FULL;
