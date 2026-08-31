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
    RETURN {
        name: string::lowercase(string::trim($name)),
        version: fn::validation_contract_version($version,"SCHEMA_VERSION"),
        definition: $definition
    };
}
COMMENT "Normalise la source d'un schéma avant compilation."
PERMISSIONS FULL;
