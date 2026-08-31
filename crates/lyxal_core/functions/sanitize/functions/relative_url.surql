-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_relative_url
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_relative_url($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $v=string::replace($v,<regex>"^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]*","");
 LET $v=string::replace($v,<regex>"^/+","/");
 RETURN IF string::starts_with($v,"/"){$v}ELSE{string::concat("/",$v)};
}
COMMENT "Transforme lexicalement une URL en chemin relatif absolu."
PERMISSIONS FULL;
