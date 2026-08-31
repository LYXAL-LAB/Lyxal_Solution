-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_html
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_html($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=fn::sanitize_strip_comments($value,$field);
 LET $v=fn::sanitize_strip_scripts($v,$field);
 LET $v=fn::sanitize_strip_styles($v,$field);
 LET $v=fn::sanitize_strip_iframes($v,$field);
 LET $v=fn::sanitize_strip_svg($v,$field);
 LET $v=fn::sanitize_strip_event_handlers($v,$field);
 RETURN fn::sanitize_strip_dangerous_attributes($v,$field);
}
COMMENT "Applique le pipeline lexical HTML du Core Sanitize."
PERMISSIONS FULL;
