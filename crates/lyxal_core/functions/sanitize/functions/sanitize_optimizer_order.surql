-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_order
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_order($pipeline:array<object>)->array<object>{
 LET $weights={default:10,normalize_unicode:20,remove_control_chars:30,trim:40,collapse_whitespace:50,lowercase:60,uppercase:60,capitalize:60,title_case:60,slug:70,safe_identifier:70};
 RETURN array::sort::asc(array::map($pipeline,|$s|object::extend($s,{_weight:IF $weights[$s.rule] IS NONE{100}ELSE{$weights[$s.rule]}})),"_weight");
}
COMMENT "Ordonne les étapes selon un ordre canonique."
PERMISSIONS FULL;
