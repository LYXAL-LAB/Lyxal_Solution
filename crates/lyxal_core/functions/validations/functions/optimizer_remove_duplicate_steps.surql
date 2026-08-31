-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_remove_duplicate_steps
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_remove_duplicate_steps($pipeline:array<object>)->array<object>{
 RETURN array::reduce($pipeline,|$result,$step|IF array::any($result,|$e|$e.rule=$step.rule AND $e.value=$step.value){$result}ELSE{array::append($result,$step)},[]);
}
COMMENT "Supprime les étapes dupliquées."
PERMISSIONS FULL;
