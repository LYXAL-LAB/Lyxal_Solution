-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/hmac_signature.surql
-- Fonction     : fn::validation_hmac_signature
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide la représentation d’une signature HMAC en hexadécimal ou Base64.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::matches()
--   - string::len()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_hmac_signature($value: option<any>, $field: string, $encoding: string, $expected_length: option<int>) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    LET $clean_encoding = string::lowercase(string::trim($encoding));
    IF $clean_encoding != "hex" AND $clean_encoding != "base64" { THROW "VALIDATION_UNSUPPORTED_HMAC_ENCODING"; };
    IF $expected_length IS NOT NONE AND $expected_length < 1 { THROW "VALIDATION_INVALID_EXPECTED_HMAC_LENGTH"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    LET $valid = IF $clean_encoding = "hex" { string::matches($clean_value, "^[0-9A-Fa-f]+$") } ELSE { string::matches($clean_value, "^[A-Za-z0-9+/]+={0,2}$") };
    IF !$valid { THROW string::concat($clean_field, "_INVALID_HMAC_SIGNATURE"); };
    IF $expected_length IS NOT NONE AND string::len($clean_value) != $expected_length { THROW string::concat($clean_field, "_INVALID_HMAC_LENGTH"); };
    RETURN IF $clean_encoding = "hex" { string::lowercase($clean_value) } ELSE { $clean_value };
}
COMMENT "Valide la représentation d'une signature HMAC; aucune comparaison cryptographique n'est effectuée." PERMISSIONS FULL;
