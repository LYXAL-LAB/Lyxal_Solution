-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/public_alias.surql
-- Fonction     : fn::validation_public_alias
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un pseudonyme public distinct d'un identifiant technique.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: int
-- $max_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_PUBLIC_ALIAS
-- VALIDATION_INVALID_PUBLIC_ALIAS_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_public_alias(
    $value: option<any>,
    $field: string,
    $min_length: int,
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

    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_PUBLIC_ALIAS_LENGTH_RANGE";
    };

    LET $length = string::len($clean_value);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $clean_value,
        "^[\p{L}\p{M}\p{N}._\-]+$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_PUBLIC_ALIAS"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un pseudonyme public Unicode composé de lettres, chiffres, points,
tirets et tirets bas.
"
PERMISSIONS FULL;
