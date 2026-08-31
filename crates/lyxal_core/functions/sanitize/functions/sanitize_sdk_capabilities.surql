-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_capabilities
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_capabilities()->array<string>{
 RETURN ["strings","text","html","markdown","urls","contact_finance","numbers","date_time","arrays","objects","pipeline","schemas","runtime","optimizer","debug","benchmark"];
}
COMMENT "Retourne les capacités publiques du SDK."
PERMISSIONS FULL;
