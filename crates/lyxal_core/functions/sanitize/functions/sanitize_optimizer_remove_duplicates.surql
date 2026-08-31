-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_remove_duplicates
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_remove_duplicates($pipeline:array<object>)->array<object>{
 RETURN array::fold($pipeline,[],|$acc,$step|IF array::any($acc,|$x|$x.rule=$step.rule AND $x.value=$step.value AND $x.options=$step.options){$acc}ELSE{array::append($acc,$step)});
}
COMMENT "Supprime les étapes strictement dupliquées."
PERMISSIONS FULL;
