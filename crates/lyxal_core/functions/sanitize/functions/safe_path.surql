-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_safe_path
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_path($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::replace(string::trim($value),"\\","/");
 LET $v=string::replace($v,<regex>"/+","/");
 LET $segments=array::filter(string::split($v,"/"),|$s|$s!="" AND $s!="." AND $s!="..");
 RETURN array::join($segments,"/");
}
COMMENT "Normalise un chemin relatif et retire les segments . et ..."
PERMISSIONS FULL;
