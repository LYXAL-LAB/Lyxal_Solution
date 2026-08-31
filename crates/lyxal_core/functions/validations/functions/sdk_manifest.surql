-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_manifest(
    $validator_registry: object,
    $schema_registry: array<object>
) -> object {
    RETURN {
        sdk: fn::validation_sdk_version(),
        capabilities: fn::validation_sdk_capabilities(),
        validators:
            fn::validation_validator_registry_manifest(
                $validator_registry
            ),
        schemas: array::map(
            $schema_registry,
            |$entry| {
                name: $entry.name,
                version: $entry.version,
                status: $entry.status
            }
        ),
        generated_at: time::now()
    };
}
COMMENT "
Produit le manifeste public complet du Validation SDK.
"
PERMISSIONS FULL;
