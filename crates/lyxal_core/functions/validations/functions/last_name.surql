-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/last_name.surql
-- Fonction     : fn::validation_last_name
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de famille avec longueur configurable et caractères Unicode courants.
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
-- <FIELD>_INVALID_LAST_NAME
-- VALIDATION_INVALID_LAST_NAME_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_last_name(
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
        THROW "VALIDATION_INVALID_LAST_NAME_LENGTH_RANGE";
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
        "^[\p{L}\p{M}]+(?:[ '\-][\p{L}\p{M}]+)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_LAST_NAME"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un nom de famille Unicode avec espaces, apostrophes et tirets internes.
"
PERMISSIONS FULL;
