-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema(
    $name: string,
    $version: string,
    $fields: object,
    $unknown_keys_policy: string
) -> object {
    LET $n = string::lowercase(string::trim($name));
    LET $v = string::lowercase(string::trim($version));
    LET $policy = string::lowercase(string::trim($unknown_keys_policy));
    IF !string::matches($n,"^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$") {
        THROW "SANITIZE_INVALID_SCHEMA_NAME";
    };
    IF !string::matches($v,"^v[1-9][0-9]*$") {
        THROW "SANITIZE_INVALID_SCHEMA_VERSION";
    };
    IF !array::contains(["allow","strip","reject"],$policy) {
        THROW "SANITIZE_INVALID_UNKNOWN_KEYS_POLICY";
    };
    IF object::is_empty($fields) { THROW "SANITIZE_EMPTY_SCHEMA"; };
    RETURN {name:$n,version:$v,fields:$fields,unknown_keys_policy:$policy};
}
COMMENT "Construit un schéma de sanitation versionné."
PERMISSIONS FULL;
