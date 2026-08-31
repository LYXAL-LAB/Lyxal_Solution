-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tuple_length.surql
-- Fonction     : fn::validation_tuple_length
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'un tableau utilisé comme tuple possède une longueur exacte.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être strictement de type array.
--   2. La longueur attendue doit être positive ou nulle.
--   3. La longueur réelle doit être exactement égale à la longueur attendue.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TUPLE_LENGTH
-- VALIDATION_INVALID_EXPECTED_TUPLE_LENGTH
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune dépendance à l'authentification ;
--   - aucun appel réseau ;
--   - aucun effet secondaire ;
--   - aucune conversion implicite de la valeur validée.
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

DEFINE FUNCTION OVERWRITE fn::validation_tuple_length(
    $value: option<any>,
    $field: string,
    $expected_length: int
) -> array {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $expected_length < 0 {
        THROW "VALIDATION_INVALID_EXPECTED_TUPLE_LENGTH";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF array::len($value) != $expected_length {
        THROW string::concat(
            $clean_field,
            "_INVALID_TUPLE_LENGTH"
        );
    };

    RETURN $value;
}
COMMENT "
Valide qu'un tableau utilisé comme tuple possède une longueur exacte.
"
PERMISSIONS FULL;
