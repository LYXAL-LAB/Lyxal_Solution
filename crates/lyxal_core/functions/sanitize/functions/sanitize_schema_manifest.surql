-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema_manifest(
    $registry: object
) -> object {
    RETURN {
        generated_at: time::now(),
        total: array::len($registry.entries),
        schemas: array::map(
            $registry.entries,
            |$entry| {
                name:$entry.name,
                version:$entry.version,
                status:$entry.status
            }
        )
    };
}
COMMENT "Produit un manifeste public du registre de schémas."
PERMISSIONS FULL;
