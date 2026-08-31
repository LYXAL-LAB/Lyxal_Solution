-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_version()->object{
 RETURN {name:"lyxal_sanitize_sdk",version:"1.0.0",contract_version:"v1",lots:"1-17"};
}
COMMENT "Retourne la version publique du SDK."
PERMISSIONS FULL;
