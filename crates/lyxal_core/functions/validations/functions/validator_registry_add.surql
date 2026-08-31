-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_add
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_add(
    $registry: object,
    $entry: object
) -> object {
    LET $without_existing = array::filter(
        $registry.entries,
        |$item| !(
            $item.name = $entry.name
            AND $item.version = $entry.version
        )
    );

    LET $entries = array::append($without_existing, $entry);

    RETURN fn::validation_validator_registry($entries);
}
COMMENT "
Ajoute ou remplace une version de validateur dans le registre.
"
PERMISSIONS FULL;
