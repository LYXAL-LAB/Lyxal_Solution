-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_database.surql
-- Fonction     : fn::validation_lyxal_database
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de database Lyxal associé à un workspace ou client final.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Elle commence par une lettre.
--   3. Les caractères autorisés sont a-z, 0-9 et tiret bas.
--   4. Les doubles tirets bas et le tiret bas final sont interdits.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: int
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_DATABASE
-- <FIELD>_REPEATED_SEPARATOR
-- VALIDATION_INVALID_DATABASE_LENGTH_RANGE
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
--   - aucun accès réseau ;
--   - aucune dépendance à l'authentification ;
--   - aucune création de ressource Lyxal ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_database(
    $value: option<any>,
    $field: string,
    $min_length: int,
    $max_length: int
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
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

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_DATABASE_LENGTH_RANGE";
    };

    LET $database = string::lowercase($clean_value);
    LET $length = string::len($database);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $database,
        "^[a-z][a-z0-9_]*[a-z0-9]$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_DATABASE"
        );
    };

    IF string::contains($database, "__") {
        THROW string::concat(
            $clean_field,
            "_REPEATED_SEPARATOR"
        );
    };

    RETURN $database;
}
COMMENT "
Valide et normalise un nom de database Lyxal associé à un workspace.
"
PERMISSIONS FULL;
