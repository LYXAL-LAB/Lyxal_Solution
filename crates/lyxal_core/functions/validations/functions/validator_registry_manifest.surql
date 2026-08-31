-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_manifest(
    $registry: object
) -> object {
    RETURN {
        generated_at: time::now(),
        validators: array::map(
            $registry.entries,
            |$entry| {
                name: $entry.name,
                version: $entry.version,
                capability: $entry.capability,
                enabled: $entry.enabled
            }
        ),
        total: array::len($registry.entries)
    };
}
COMMENT "
Produit un manifeste public du registre de validateurs.
"
PERMISSIONS FULL;
