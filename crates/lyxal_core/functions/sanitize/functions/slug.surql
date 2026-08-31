-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_slug
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_slug($value:option<any>,$field:string,$separator:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $sep=IF $separator=""{"-"}ELSE{$separator};
 LET $v=string::lowercase(string::trim($value));
 LET $v=string::replace($v,<regex>"[^a-z0-9]+",$sep);
 LET $v=string::replace($v,<regex>string::concat("^",<string>$sep,"+"),"");
 LET $v=string::replace($v,<regex>string::concat(<string>$sep,"+$"),"");
 RETURN $v;
}
COMMENT "Produit un slug ASCII simple."
PERMISSIONS FULL;
