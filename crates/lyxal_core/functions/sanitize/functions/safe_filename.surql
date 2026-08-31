-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_safe_filename
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_filename($value:option<any>,$field:string,$replacement:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $r=IF $replacement=""{"_"}ELSE{$replacement};
 LET $v=string::trim($value);
 LET $v=string::replace($v,<regex>"[<>:\"/\\|?*\x00-\x1F]",$r);
 LET $v=string::replace($v,<regex>"[. ]+$","");
 RETURN $v;
}
COMMENT "Nettoie un nom de fichier en retirant les caractères interdits courants."
PERMISSIONS FULL;
