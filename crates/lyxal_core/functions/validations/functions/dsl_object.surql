-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_object(
    $name: string,
    $version: string,
    $fields: object
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_version = string::lowercase(string::trim($version));

    IF !string::matches(
        $clean_name,
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"
    ) {
        THROW "VALIDATION_DSL_INVALID_OBJECT_NAME";
    };

    IF !string::matches($clean_version, "^v[1-9][0-9]*$") {
        THROW "VALIDATION_DSL_INVALID_VERSION";
    };

    IF object::is_empty($fields) {
        THROW "VALIDATION_DSL_EMPTY_OBJECT";
    };

    RETURN {
        name: $clean_name,
        version: $clean_version,
        fields: $fields
    };
}
COMMENT "
Construit un objet DSL de validation versionné.
"
PERMISSIONS FULL;
