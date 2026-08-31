-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_field($session:object,$field:string)->array<object>{
 LET $f=string::trim($field);
 RETURN array::filter($session.traces,|$t|$t.field=$f);
}
COMMENT "Retourne les traces d'un champ."
PERMISSIONS FULL;
