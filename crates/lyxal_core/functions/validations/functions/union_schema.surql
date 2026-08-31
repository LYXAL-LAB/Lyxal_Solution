-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_union_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_union_schema(
    $value: any,
    $field: string,
    $allowed_types: array<string>
) -> any {
    LET $clean_field = string::trim($field);
    LET $actual = string::lowercase(type::of($value));
    LET $allowed = array::map($allowed_types, |$t| string::lowercase(string::trim($t)));
    IF !array::contains($allowed, $actual) {
        THROW string::concat($clean_field, "_UNION_TYPE_NOT_ALLOWED");
    };
    RETURN $value;
}
COMMENT "Valide une union simple de types."
PERMISSIONS FULL;
