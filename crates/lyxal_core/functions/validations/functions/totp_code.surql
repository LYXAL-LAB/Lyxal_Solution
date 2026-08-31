-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/totp_code.surql
-- Fonction     : fn::validation_totp_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un code TOTP numérique à 6 ou 8 chiffres.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $digits: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TOTP_CODE
-- VALIDATION_INVALID_TOTP_DIGITS
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive pure : aucune lecture ou écriture persistante, aucun appel réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::matches()
--   - string::len()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_totp_code(
    $value: option<any>,
    $field: string,
    $digits: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF $digits != 6 AND $digits != 8 {
        THROW "VALIDATION_INVALID_TOTP_DIGITS";
    };

    IF string::len($clean_value) != $digits
        OR !string::matches($clean_value, "^[0-9]+$")
    {
        THROW string::concat($clean_field, "_INVALID_TOTP_CODE");
    };

    RETURN $clean_value;
}
COMMENT "
Valide lexicalement un code TOTP numérique à six ou huit chiffres.
"
PERMISSIONS FULL;
