-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_html_entities
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_html_entities($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::replace($value,"&","&amp;");
 LET $v=string::replace($v,"<","&lt;");
 LET $v=string::replace($v,">","&gt;");
 LET $v=string::replace($v,"\"","&quot;");
 RETURN string::replace($v,"'","&#39;");
}
COMMENT "Encode les cinq caractères HTML les plus sensibles."
PERMISSIONS FULL;
