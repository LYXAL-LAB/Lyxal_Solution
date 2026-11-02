-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_manifest(
    $schema_registry: object
) -> object {
    RETURN {
        sdk:fn::security_sdk_version(),
        capabilities:fn::security_sdk_capabilities(),
        schemas:fn::security_schema_manifest($schema_registry),
        generated_at:time::now()
    };
}
COMMENT "Produit le manifeste public complet du Security SDK."
PERMISSIONS FULL;
