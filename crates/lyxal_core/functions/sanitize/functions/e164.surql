-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_e164
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_e164($value:option<any>,$field:string,$default_country_code:option<string>)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=fn::sanitize_phone($value,$field);
 IF string::starts_with($v,"+"){RETURN $v;};
 LET $cc=IF $default_country_code IS NONE{""}ELSE{string::replace($default_country_code,<regex>"[^0-9]","")};
 LET $digits=string::replace($v,<regex>"^0+","");
 RETURN IF $cc=""{$digits}ELSE{string::concat("+",$cc,$digits)};
}
COMMENT "Normalise lexicalement un téléphone vers une forme E.164."
PERMISSIONS FULL;
