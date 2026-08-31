-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_validate_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_validate_pipeline($pipeline:array<object>)->array<object>{
 IF array::any($pipeline,|$s|$s.rule="lowercase") AND array::any($pipeline,|$s|$s.rule="uppercase"){THROW "VALIDATION_OPTIMIZER_CONFLICTING_CASE_STEPS";};
 LET $mins=array::map(array::filter($pipeline,|$s|$s.rule="min_length"),|$s|$s.value);
 LET $maxs=array::map(array::filter($pipeline,|$s|$s.rule="max_length"),|$s|$s.value);
 IF array::len($mins)>0 AND array::len($maxs)>0 AND math::max($mins)>math::min($maxs){THROW "VALIDATION_OPTIMIZER_INVALID_LENGTH_RANGE";};
 RETURN $pipeline;
}
COMMENT "Vérifie la cohérence d'un pipeline."
PERMISSIONS FULL;
