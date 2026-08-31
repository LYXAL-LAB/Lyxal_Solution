-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_failed
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_failed($session:object)->array<object>{
 RETURN array::filter($session.traces,|$t|$t.error_code IS NOT NONE);
}
COMMENT "Retourne les traces en erreur."
PERMISSIONS FULL;
