-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema_registry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema_registry(
    $entries: array<object>
) -> object {
    RETURN {
        entries: $entries,
        total: array::len($entries),
        active: array::len(array::filter($entries, |$entry| $entry.status = "active"))
    };
}
COMMENT "Construit un registre de schémas."
PERMISSIONS FULL;
