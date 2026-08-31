-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_remove
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_remove(
    $registry: object,
    $name: string,
    $version: option<string>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_version = IF $version IS NONE {
        NONE
    } ELSE {
        string::lowercase(string::trim($version))
    };

    LET $entries = array::filter(
        $registry.entries,
        |$entry|
            $entry.name != $clean_name
            OR (
                $clean_version IS NOT NONE
                AND $entry.version != $clean_version
            )
    );

    RETURN fn::validation_validator_registry($entries);
}
COMMENT "
Supprime un validateur ou une version précise du registre.
"
PERMISSIONS FULL;
