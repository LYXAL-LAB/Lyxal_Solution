-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_pipeline_cost
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_pipeline_cost($pipeline:array<object>)->int{
 RETURN array::fold($pipeline,0,|$cost,$step|$cost+fn::validation_optimizer_step_cost($step));
}
COMMENT "Calcule le coût relatif d'un pipeline."
PERMISSIONS FULL;
