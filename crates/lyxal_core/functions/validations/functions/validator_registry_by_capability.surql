-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_by_capability
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_by_capability(
    $registry: object,
    $capability: string,
    $enabled_only: bool
) -> array<object> {
    LET $clean_capability = fn::validation_validator_capability(
        $capability,
        "CAPABILITY"
    );

    RETURN array::filter(
        $registry.entries,
        |$entry|
            $entry.capability = $clean_capability
            AND (
                !$enabled_only
                OR $entry.enabled = true
            )
    );
}
COMMENT "
Retourne les validateurs d'une capacité donnée.
"
PERMISSIONS FULL;
