-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_validate($pipeline:array<object>)->array<object>{
 IF array::any($pipeline,|$s|$s.rule="lowercase") AND array::any($pipeline,|$s|$s.rule="uppercase"){THROW "SANITIZE_OPTIMIZER_CONFLICTING_CASE_RULES";};
 RETURN $pipeline;
}
COMMENT "Vérifie la cohérence d'un pipeline avant optimisation."
PERMISSIONS FULL;
