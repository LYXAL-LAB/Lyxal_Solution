-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_order
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_order($pipeline:array<object>)->array<object>{
 LET $weights={default:10,normalize_unicode:20,remove_control_chars:30,trim:40,collapse_whitespace:50,lowercase:60,uppercase:60,capitalize:60,title_case:60,slug:70,safe_identifier:70};
 LET $weighted = array::map($pipeline,|$s|object::extend($s,{_weight:IF $weights[$s.rule] IS NONE{100}ELSE{$weights[$s.rule]}}));
 RETURN array::fold($weighted,[],|$acc,$item|{LET $before=array::filter($acc,|$x|$x._weight<=$item._weight);LET $after=array::filter($acc,|$x|$x._weight>$item._weight);array::concat(array::append($before,$item),$after)});
}
COMMENT "Ordonne les étapes selon un ordre canonique."
PERMISSIONS FULL;
