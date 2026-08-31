-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_domain
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_domain($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::lowercase(string::trim($value));
 LET $v=string::replace($v,<regex>"^https?://","");
 LET $v=string::split($v,"/")[0];
 LET $v=string::split($v,":")[0];
 RETURN string::replace($v,<regex>"\.+$","");
}
COMMENT "Extrait et normalise lexicalement un domaine."
PERMISSIONS FULL;
