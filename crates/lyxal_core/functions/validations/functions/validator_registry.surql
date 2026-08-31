-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry(
    $entries: array<object>
) -> object {
    LET $enabled = array::filter(
        $entries,
        |$entry| $entry.enabled = true
    );

    RETURN {
        entries: $entries,
        total: array::len($entries),
        enabled_count: array::len($enabled),
        disabled_count: array::len($entries) - array::len($enabled)
    };
}
COMMENT "
Construit un registre de validateurs et ses compteurs.
"
PERMISSIONS FULL;
