-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_strip_dangerous_attributes
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_strip_dangerous_attributes($value:any,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::replace($value,<regex>"(?i)\\s+(style|srcdoc)\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)","");
 LET $v2=string::replace($v,<regex>"(?i)href\\s*=\\s*(\"\\s*javascript:[^\"]*\"|'\\s*javascript:[^']*')","href=\"#\"");
 RETURN string::replace($v2,<regex>"(?i)src\\s*=\\s*(\"\\s*javascript:[^\"]*\"|'\\s*javascript:[^']*')","src=\"#\"");
}
COMMENT "Supprime quelques attributs HTML dangereux courants."
PERMISSIONS FULL;
