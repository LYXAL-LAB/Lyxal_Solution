-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/password_strength.surql
-- Fonction     : fn::validation_password_strength
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement la robustesse minimale d'un mot de passe sans le stocker ni le hacher.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: int
-- $max_length: int
-- $require_uppercase: bool
-- $require_lowercase: bool
-- $require_digit: bool
-- $require_special: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_UPPERCASE_REQUIRED
-- <FIELD>_LOWERCASE_REQUIRED
-- <FIELD>_DIGIT_REQUIRED
-- <FIELD>_SPECIAL_CHARACTER_REQUIRED
-- VALIDATION_INVALID_PASSWORD_LENGTH_RANGE
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
--   - string::len()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- Sécurité
-- --------
-- Cette fonction ne remplace pas un hash Argon2, scrypt, bcrypt ou PBKDF2.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_password_strength(
    $value: option<any>,
    $field: string,
    $min_length: int,
    $max_length: int,
    $require_uppercase: bool,
    $require_lowercase: bool,
    $require_digit: bool,
    $require_special: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_PASSWORD_LENGTH_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $length = string::len($value);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF $require_uppercase AND !string::matches($value, "[A-Z]") {
        THROW string::concat($clean_field, "_UPPERCASE_REQUIRED");
    };

    IF $require_lowercase AND !string::matches($value, "[a-z]") {
        THROW string::concat($clean_field, "_LOWERCASE_REQUIRED");
    };

    IF $require_digit AND !string::matches($value, "[0-9]") {
        THROW string::concat($clean_field, "_DIGIT_REQUIRED");
    };

    IF $require_special AND !string::matches($value, "[^A-Za-z0-9]") {
        THROW string::concat(
            $clean_field,
            "_SPECIAL_CHARACTER_REQUIRED"
        );
    };

    RETURN $value;
}
COMMENT "
Valide la longueur et les classes de caractères minimales d'un mot de passe.
"
PERMISSIONS FULL;
