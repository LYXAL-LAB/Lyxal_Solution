-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_source
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_source(
    $name: string,
    $version: string,
    $definition: object
) -> object {
    LET $version_check = fn::validation_contract_version($version);
    IF !$version_check.valid {
        THROW "SCHEMA_VERSION_INVALID_CONTRACT_VERSION";
    };
    RETURN {
        name: string::lowercase(string::trim($name)),
        version: $version_check.value,
        definition: $definition
    };
}
COMMENT "Normalise la source d'un schéma avant compilation."
PERMISSIONS FULL;
