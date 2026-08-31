-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_object($schema:object,$payload:object,$options:option<object>)->object{
 RETURN fn::sanitize_sdk_execute($schema,$payload,$options);
}
COMMENT "Sanitise un objet via l'API publique."
PERMISSIONS FULL;
