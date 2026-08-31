-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/integer_range.surql
-- Fonction     : fn::validation_integer_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une plage composée d'un entier minimum et d'un entier maximum.
--
-- Principes
-- ----------
--   - validation stricte sans conversion implicite ;
--   - distinction entre NONE, NULL et type invalide ;
--   - codes d'erreur stables ;
--   - aucune lecture ou écriture persistante ;
--   - retour de la valeur d'origine lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $min_value: option<any>
-- $max_value: option<any>
-- $field: string
-- $allow_equal: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_MIN_REQUIRED / _MIN_NULL_NOT_ALLOWED / _MIN_INVALID_TYPE
-- <FIELD>_MAX_REQUIRED / _MAX_NULL_NOT_ALLOWED / _MAX_INVALID_TYPE
-- <FIELD>_INVALID_ORDER
-- <FIELD>_EQUAL_BOUNDS_NOT_ALLOWED
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
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_int()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_integer_range(
    $min_value: option<any>,
    $max_value: option<any>,
    $field: string,
    $allow_equal: bool
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_value IS NONE {
        THROW string::concat($clean_field, "_MIN_REQUIRED");
    };

    IF type::is_null($min_value) {
        THROW string::concat($clean_field, "_MIN_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($min_value) {
        THROW string::concat($clean_field, "_MIN_INVALID_TYPE");
    };

    IF $max_value IS NONE {
        THROW string::concat($clean_field, "_MAX_REQUIRED");
    };

    IF type::is_null($max_value) {
        THROW string::concat($clean_field, "_MAX_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($max_value) {
        THROW string::concat($clean_field, "_MAX_INVALID_TYPE");
    };

    IF $max_value < $min_value {
        THROW string::concat($clean_field, "_INVALID_ORDER");
    };

    IF !$allow_equal AND $max_value = $min_value {
        THROW string::concat($clean_field, "_EQUAL_BOUNDS_NOT_ALLOWED");
    };

    RETURN {
        min_value: $min_value,
        max_value: $max_value,
        span: $max_value - $min_value
    };
}
COMMENT "
Valide une plage d'entiers et retourne les deux bornes ainsi que leur écart.
"
PERMISSIONS FULL;
