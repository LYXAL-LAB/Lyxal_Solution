-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_reference
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_reference(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $ref = string::lowercase(string::trim($value));
    IF !string::matches($ref, "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*@v[0-9]+$") {
        THROW string::concat($clean_field, "_INVALID_SCHEMA_REFERENCE");
    };
    RETURN $ref;
}
COMMENT "Valide une référence versionnée de schéma."
PERMISSIONS FULL;
