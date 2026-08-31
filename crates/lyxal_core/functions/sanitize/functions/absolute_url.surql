-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_absolute_url
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_absolute_url($value:option<any>,$field:string,$default_scheme:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $scheme=string::lowercase(string::trim($default_scheme));
 RETURN IF string::matches($v,"^[a-zA-Z][a-zA-Z0-9+.-]*://"){$v}ELSE{string::concat($scheme,"://",$v)};
}
COMMENT "Ajoute un schéma par défaut lorsqu'il est absent."
PERMISSIONS FULL;
