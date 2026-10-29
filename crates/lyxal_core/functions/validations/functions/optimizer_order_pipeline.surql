-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_order_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_order_pipeline($pipeline:array<object>)->array<object>{
 LET $weights={default:10,required:20,trim:30,lowercase:40,uppercase:40,min_length:50,max_length:50,enum:60,pattern:70};
 LET $weighted = array::map($pipeline,|$s|object::extend($s,{_weight:IF $weights[$s.rule] IS NONE{100}ELSE{$weights[$s.rule]}}));
 RETURN array::fold($weighted,[],|$acc,$item|{LET $before=array::filter($acc,|$x|$x._weight<=$item._weight);LET $after=array::filter($acc,|$x|$x._weight>$item._weight);array::concat(array::append($before,$item),$after)});
}
COMMENT "Ordonne un pipeline selon un ordre canonique."
PERMISSIONS FULL;
