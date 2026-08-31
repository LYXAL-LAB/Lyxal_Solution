-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_key
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_key(
    $name: string,
    $version: string,
    $source_hash: string
) -> string {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_version = string::lowercase(string::trim($version));
    LET $clean_hash = string::lowercase(string::trim($source_hash));

    IF !string::matches(
        $clean_name,
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"
    ) {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_NAME";
    };

    IF !string::matches($clean_version, "^v[1-9][0-9]*$") {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_VERSION";
    };

    IF !string::matches($clean_hash, "^[0-9a-f]{8,128}$") {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_HASH";
    };

    RETURN string::concat(
        $clean_name,
        "@",
        $clean_version,
        ":",
        $clean_hash
    );
}
COMMENT "
Construit une clé de cache déterministe pour un schéma compilé.
"
PERMISSIONS FULL;
