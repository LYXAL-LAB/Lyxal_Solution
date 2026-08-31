-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/full_name.surql
-- Fonction     : fn::validation_full_name
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom complet composé de plusieurs segments humains.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_words: int
-- $max_words: int
-- $max_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_FULL_NAME
-- <FIELD>_TOO_FEW_WORDS
-- <FIELD>_TOO_MANY_WORDS
-- VALIDATION_INVALID_FULL_NAME_LIMITS
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune dépendance à l'authentification ;
--   - aucune consultation de registre externe ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_full_name(
    $value: option<any>,
    $field: string,
    $min_words: int,
    $max_words: int,
    $max_length: int
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

    IF $min_words < 1
        OR $max_words < 1
        OR $min_words > $max_words
        OR $max_length < 1
    {
        THROW "VALIDATION_INVALID_FULL_NAME_LIMITS";
    };

    IF string::len($clean_value) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $clean_value,
        "^[\p{L}\p{M}]+(?:[ '\-][\p{L}\p{M}]+)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FULL_NAME"
        );
    };

    LET $words = string::split($clean_value, " ");
    LET $word_count = array::len($words);

    IF $word_count < $min_words {
        THROW string::concat($clean_field, "_TOO_FEW_WORDS");
    };

    IF $word_count > $max_words {
        THROW string::concat($clean_field, "_TOO_MANY_WORDS");
    };

    RETURN $clean_value;
}
COMMENT "
Valide un nom complet humain avec nombre de mots et longueur configurables.
"
PERMISSIONS FULL;
