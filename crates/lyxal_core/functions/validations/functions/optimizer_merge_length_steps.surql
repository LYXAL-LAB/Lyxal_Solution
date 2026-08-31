-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_merge_length_steps
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_merge_length_steps($pipeline:array<object>)->array<object>{
 LET $mins=array::map(array::filter($pipeline,|$s|$s.rule="min_length"),|$s|$s.value);
 LET $maxs=array::map(array::filter($pipeline,|$s|$s.rule="max_length"),|$s|$s.value);
 LET $base=array::filter($pipeline,|$s|!array::contains(["min_length","max_length"],$s.rule));
 LET $with_min=IF array::len($mins)=0{$base}ELSE{array::append($base,{rule:"min_length",value:math::max($mins)})};
 RETURN IF array::len($maxs)=0{$with_min}ELSE{array::append($with_min,{rule:"max_length",value:math::min($maxs)})};
}
COMMENT "Fusionne les contraintes de longueur."
PERMISSIONS FULL;
