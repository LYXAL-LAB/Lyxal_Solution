-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_remove_tracking
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_tracking($value:option<any>,$field:string)->string{
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

 LET $v=string::trim($value);
 LET $v=string::replace($v,<regex>"([?&])(utm_[^=&]+|fbclid|gclid|mc_cid|mc_eid)=[^&#]*","$1");
 LET $v=string::replace($v,<regex>"[?&]+$","");
 LET $v=string::replace($v,"?&","?");
 LET $v=string::replace($v,"&&","&");
 RETURN $v;
}
COMMENT "Supprime plusieurs paramètres de suivi courants."
PERMISSIONS FULL;
