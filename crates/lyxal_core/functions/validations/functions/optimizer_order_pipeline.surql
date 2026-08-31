-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_order_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_order_pipeline($pipeline:array<object>)->array<object>{
 LET $weights={default:10,required:20,trim:30,lowercase:40,uppercase:40,min_length:50,max_length:50,enum:60,pattern:70};
 RETURN array::sort::asc(array::map($pipeline,|$s|object::extend($s,{_weight:IF $weights[$s.rule] IS NONE{100}ELSE{$weights[$s.rule]}})),"_weight");
}
COMMENT "Ordonne un pipeline selon un ordre canonique."
PERMISSIONS FULL;
