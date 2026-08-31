-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_integers.surql
-- Fonction     : fn::validation_array_integers
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que tous les éléments d'un tableau sont strictement de type int et respectent des bornes facultatives.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_value: option<int>
-- $max_value: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_ITEM_TYPE
-- <FIELD>_ITEM_TOO_SMALL
-- <FIELD>_ITEM_TOO_LARGE
-- VALIDATION_INVALID_INTEGER_ITEM_RANGE
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
--   - type::is_int()
--   - array::all()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_integers(
    $value: option<any>,
    $field: string,
    $min_value: option<int>,
    $max_value: option<int>
) -> array<int> {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_INTEGER_ITEM_RANGE";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !array::all($value, |$item| type::is_int($item)) {
        THROW string::concat($clean_field, "_INVALID_ITEM_TYPE");
    };

    IF $min_value IS NOT NONE
        AND array::any($value, |$item| $item < $min_value)
    {
        THROW string::concat($clean_field, "_ITEM_TOO_SMALL");
    };

    IF $max_value IS NOT NONE
        AND array::any($value, |$item| $item > $max_value)
    {
        THROW string::concat($clean_field, "_ITEM_TOO_LARGE");
    };

    RETURN $value;
}
COMMENT "
Valide que tous les éléments d'un tableau sont des entiers dans des bornes
facultatives.
"
PERMISSIONS FULL;
