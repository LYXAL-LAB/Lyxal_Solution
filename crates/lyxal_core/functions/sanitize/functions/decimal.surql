-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_decimal
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_decimal($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $sign=IF string::starts_with($v,"-"){"-"}ELSE{""};
 LET $v=string::replace($v,",",".");
 LET $v=string::replace($v,<regex>"[^0-9.]","");
 LET $parts=string::split($v,".");
 RETURN IF array::len($parts)<=1{string::concat($sign,$v)}ELSE{string::concat($sign,$parts[0],".",array::join(array::slice($parts,1,array::len($parts)),""))};
}
COMMENT "Normalise une représentation décimale avec un seul point."
PERMISSIONS FULL;
