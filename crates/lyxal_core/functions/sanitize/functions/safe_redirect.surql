-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_safe_redirect
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_redirect($value:option<any>,$field:string,$fallback:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 IF string::starts_with($v,"//"){RETURN $fallback;};
 IF string::matches(string::lowercase($v),"^(javascript|data|vbscript):"){RETURN $fallback;};
 RETURN IF string::starts_with($v,"/"){$v}ELSE{$fallback};
}
COMMENT "Conserve uniquement une redirection relative sûre."
PERMISSIONS FULL;
