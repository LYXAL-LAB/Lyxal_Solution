-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_nested_array
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_nested_array(
    $value: option<any>,
    $field: string,
    $item_schema: object,
    $min_items: option<int>,
    $max_items: option<int>
) -> array<object> {
    LET $clean_field = string::trim($field);
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF !type::is_array($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $count = array::len($value);
    IF $min_items IS NOT NONE AND $count < $min_items { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $max_items IS NOT NONE AND $count > $max_items { THROW string::concat($clean_field, "_TOO_LONG"); };
    RETURN array::map($value, |$item| fn::validation_validate_object($item, $clean_field, $item_schema, false));
}
COMMENT "Valide un tableau d'objets imbriqués."
PERMISSIONS FULL;
