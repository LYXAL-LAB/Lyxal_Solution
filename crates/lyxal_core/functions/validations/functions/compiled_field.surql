-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_field(
    $compiled_schema: object,
    $field: string
) -> array<object> {
    LET $clean_field = string::trim($field);
    IF !array::contains(object::keys($compiled_schema.fields),$clean_field) {
        THROW "VALIDATION_COMPILED_FIELD_NOT_FOUND";
    };
    RETURN $compiled_schema.fields[$clean_field];
}
COMMENT "Extrait le pipeline compilé d'un champ."
PERMISSIONS FULL;
