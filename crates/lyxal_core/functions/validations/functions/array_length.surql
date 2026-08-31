-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_length.surql
-- Fonction     : fn::validation_array_length
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide la longueur minimale et maximale d'un tableau obligatoire.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: option<int>
-- $max_length: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_ARRAY_MIN_LENGTH
-- VALIDATION_INVALID_ARRAY_MAX_LENGTH
-- VALIDATION_INVALID_ARRAY_LENGTH_RANGE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive pure : aucune lecture ou écriture persistante, aucun accès réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - array::len()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_length(
    $value: option<any>,
    $field: string,
    $min_length: option<int>,
    $max_length: option<int>
) -> array {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $min_length IS NOT NONE AND $min_length < 0 {
        THROW "VALIDATION_INVALID_ARRAY_MIN_LENGTH";
    };
    IF $max_length IS NOT NONE AND $max_length < 0 {
        THROW "VALIDATION_INVALID_ARRAY_MAX_LENGTH";
    };
    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_ARRAY_LENGTH_RANGE";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $length = array::len($value);

    IF $min_length IS NOT NONE AND $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    RETURN $value;
}
COMMENT "
Valide la longueur inclusive minimale et maximale d'un tableau obligatoire.
"
PERMISSIONS FULL;
