-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/content_type.surql
-- Fonction     : fn::validation_content_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un en-tête Content-Type et son type MIME principal.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::split()
--   - string::matches()
--   - array::contains()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_content_type($value: option<any>, $field: string, $allowed_media_types: option<array<string>>) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $normalized = string::lowercase($clean_value);
    LET $parts = string::split($normalized, ";");
    LET $media_type = string::trim($parts[0]);
    IF !string::matches($media_type, "^[a-z0-9!#$&^_.+-]+/[a-z0-9!#$&^_.+-]+$") { THROW string::concat($clean_field, "_INVALID_CONTENT_TYPE"); };
    IF $allowed_media_types IS NOT NONE {
        IF array::len($allowed_media_types) = 0 { THROW "VALIDATION_EMPTY_ALLOWED_MEDIA_TYPES"; };
        LET $allowed = array::map($allowed_media_types, |$item| string::lowercase(string::trim($item)));
        IF !array::contains($allowed, $media_type) { THROW string::concat($clean_field, "_MEDIA_TYPE_NOT_ALLOWED"); };
    };
    RETURN $normalized;
}
COMMENT "Valide un Content-Type et limite facultativement son type MIME."
PERMISSIONS FULL;
