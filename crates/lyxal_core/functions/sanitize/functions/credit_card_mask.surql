-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_credit_card_mask
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_credit_card_mask($value:option<any>,$field:string,$visible_digits:int)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 IF $visible_digits<0{THROW "SANITIZE_INVALID_VISIBLE_DIGITS";};
 LET $digits=string::replace($value,<regex>"[^0-9]","");
 LET $len=string::len($digits);
 IF $visible_digits>=$len{RETURN $digits;};
 LET $hidden=$len-$visible_digits;
 RETURN string::concat(string::repeat("*",$hidden),string::slice($digits,$hidden,$len));
}
COMMENT "Masque un numéro de carte en conservant les derniers chiffres."
PERMISSIONS FULL;
