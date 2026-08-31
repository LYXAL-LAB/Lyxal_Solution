-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_markdown
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=fn::sanitize_markdown_images($value,$field);
 LET $v=fn::sanitize_markdown_links($v,$field);
 LET $v=fn::sanitize_markdown_code($v,$field);
 LET $v=fn::sanitize_markdown_headers($v,$field);
 LET $v=fn::sanitize_markdown_quotes($v,$field);
 LET $v=fn::sanitize_markdown_lists($v,$field);
 LET $v=fn::sanitize_markdown_tables($v,$field);
 RETURN fn::sanitize_markdown_html($v,$field);
}
COMMENT "Aplati le Markdown vers du texte brut."
PERMISSIONS FULL;
