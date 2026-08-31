-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_currency
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_currency($value:option<any>,$field:string,$decimal_separator:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $v=string::replace($v,<regex>"[€$£¥A-Za-z\s]","");
 RETURN fn::sanitize_float($v,$field,$decimal_separator);
}
COMMENT "Retire les symboles et libellés monétaires d'un montant textuel."
PERMISSIONS FULL;
