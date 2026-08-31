-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/profile_identifier.surql
-- Fonction     : fn::validation_profile_identifier
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un identifiant public de profil stable, ASCII et URL-compatible.
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
-- <FIELD>_INVALID_PROFILE_IDENTIFIER
-- <FIELD>_INVALID_BOUNDARY
-- VALIDATION_INVALID_PROFILE_IDENTIFIER_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_profile_identifier(
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
        THROW "VALIDATION_INVALID_PROFILE_IDENTIFIER_LENGTH_RANGE";
    };

    LET $identifier = string::lowercase($clean_value);
    LET $length = string::len($identifier);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $identifier,
        "^[a-z0-9][a-z0-9._-]*[a-z0-9]$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_PROFILE_IDENTIFIER"
        );
    };

    IF string::contains($identifier, "..")
        OR string::contains($identifier, "__")
        OR string::contains($identifier, "--")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_BOUNDARY"
        );
    };

    RETURN $identifier;
}
COMMENT "
Valide et normalise un identifiant public de profil ASCII et URL-compatible.
"
PERMISSIONS FULL;
