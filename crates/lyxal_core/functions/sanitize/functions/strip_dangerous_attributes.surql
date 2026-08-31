-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_strip_dangerous_attributes
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_strip_dangerous_attributes($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::replace($value,<regex>"(?i)\s+(style|srcdoc)\s*=\s*(\"[^\"]*\"|'[^']*'|[^\s>]+)","");
 RETURN string::replace($v,<regex>"(?i)(href|src)\s*=\s*(['\"])\s*javascript:[^'\"]*\2","$1=\"#\"");
}
COMMENT "Supprime quelques attributs HTML dangereux courants."
PERMISSIONS FULL;
