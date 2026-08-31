-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_nested_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_nested_object(
    $value: option<any>,
    $field: string,
    $schema: object,
    $allow_unknown_keys: bool
) -> object {
    IF $value IS NONE { THROW string::concat(string::trim($field), "_REQUIRED"); };
    IF !type::is_object($value) { THROW string::concat(string::trim($field), "_INVALID_TYPE"); };
    RETURN fn::validation_validate_object($value, $field, $schema, $allow_unknown_keys);
}
COMMENT "Valide un objet imbriqué avec un schéma déclaratif."
PERMISSIONS FULL;
