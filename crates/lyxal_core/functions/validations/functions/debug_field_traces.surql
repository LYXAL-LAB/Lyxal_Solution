-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_field_traces
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_field_traces($session:object,$field:string)->array<object>{
 LET $clean=string::trim($field);
 RETURN array::filter($session.traces,|$t|$t.field=$clean);
}
COMMENT "Retourne les traces d'un champ."
PERMISSIONS FULL;
