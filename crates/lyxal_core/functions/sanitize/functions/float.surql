-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_float
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_float($value:option<any>,$field:string,$decimal_separator:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $sep=IF $decimal_separator=","{","}ELSE{"."};
 LET $sign=IF string::starts_with($v,"-"){"-"}ELSE{""};
 LET $v=string::replace($v,<regex>"[^0-9.,]","");
 LET $v=string::replace($v,IF $sep=","{"."}ELSE{","},"");
 LET $v=string::replace($v,$sep,".");
 RETURN string::concat($sign,$v);
}
COMMENT "Nettoie une représentation textuelle de nombre flottant."
PERMISSIONS FULL;
