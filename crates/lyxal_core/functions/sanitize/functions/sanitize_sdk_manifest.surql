-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_manifest($schema_registry:object)->object{
 RETURN {sdk:fn::sanitize_sdk_version(),capabilities:fn::sanitize_sdk_capabilities(),schemas:fn::sanitize_schema_manifest($schema_registry),generated_at:time::now()};
}
COMMENT "Produit le manifeste public complet du SDK."
PERMISSIONS FULL;
