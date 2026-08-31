-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_registry_find
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_registry_find(
    $registry: object,
    $name: string,
    $version: option<string>,
    $enabled_only: bool
) -> option<object> {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_version = IF $version IS NONE {
        NONE
    } ELSE {
        string::lowercase(string::trim($version))
    };

    LET $matches = array::filter(
        $registry.entries,
        |$entry|
            $entry.name = $clean_name
            AND (
                $clean_version IS NONE
                OR $entry.version = $clean_version
            )
            AND (
                !$enabled_only
                OR $entry.enabled = true
            )
    );

    RETURN IF array::len($matches) = 0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "
Recherche un validateur dans le registre.
"
PERMISSIONS FULL;
