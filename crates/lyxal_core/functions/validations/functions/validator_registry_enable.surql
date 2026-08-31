-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_enable
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_enable(
    $registry: object,
    $name: string,
    $enabled: bool
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    LET $entries = array::map(
        $registry.entries,
        |$entry| IF $entry.name = $clean_name {
            object::extend($entry, {enabled:$enabled})
        } ELSE {
            $entry
        }
    );

    RETURN fn::validation_validator_registry($entries);
}
COMMENT "
Active ou désactive toutes les versions d'un validateur.
"
PERMISSIONS FULL;
