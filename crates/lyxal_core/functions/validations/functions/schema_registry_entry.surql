-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_registry_entry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_registry_entry(
    $name: string,
    $version: int,
    $schema: object,
    $status: string
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_status = string::lowercase(string::trim($status));
    IF !string::matches($clean_name, "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$") {
        THROW "VALIDATION_INVALID_SCHEMA_NAME";
    };
    IF $version < 1 { THROW "VALIDATION_INVALID_SCHEMA_VERSION"; };
    IF !array::contains(["draft","active","deprecated"], $clean_status) {
        THROW "VALIDATION_INVALID_SCHEMA_STATUS";
    };
    RETURN {name:$clean_name,version:$version,schema:$schema,status:$clean_status};
}
COMMENT "Construit une entrée de registre de schéma."
PERMISSIONS FULL;
