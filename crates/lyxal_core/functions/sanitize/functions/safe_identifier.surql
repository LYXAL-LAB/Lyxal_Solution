-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_safe_identifier
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_identifier($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::lowercase(string::trim($value));
 LET $v=string::replace($v,<regex>"[^a-z0-9_]","_");
 LET $v=string::replace($v,<regex>"_+","_");
 LET $v=string::replace($v,<regex>"^_+|_+$","");
 RETURN IF string::matches($v,"^[0-9]"){string::concat("_",$v)}ELSE{$v};
}
COMMENT "Produit un identifiant ASCII sûr à base de lettres, chiffres et tirets bas."
PERMISSIONS FULL;
