-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_hash
DEFINE FUNCTION OVERWRITE fn::validation_hash(
    $value: option<any>, $field: string, $algorithm: string
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    LET $algo = string::lowercase(string::trim($algorithm));
    IF !array::contains(["md5", "sha1", "sha256", "sha384", "sha512"], $algo) {
        THROW "VALIDATION_UNSUPPORTED_HASH_ALGORITHM";
    };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $expected = IF $algo = "md5" { 32 } ELSE IF $algo = "sha1" { 40 }
        ELSE IF $algo = "sha256" { 64 } ELSE IF $algo = "sha384" { 96 } ELSE { 128 };
    IF !string::matches($clean_value, "^[0-9A-Fa-f]+$") { THROW string::concat($clean_field, "_INVALID_HASH"); };
    IF string::len($clean_value) != $expected { THROW string::concat($clean_field, "_INVALID_HASH_LENGTH"); };
    RETURN string::lowercase($clean_value);
}
COMMENT "Valide la représentation hexadécimale d'un hash selon l'algorithme déclaré."
PERMISSIONS FULL;
