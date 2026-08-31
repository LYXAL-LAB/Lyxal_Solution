-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tuple_types.surql
-- Fonction     : fn::validation_tuple_types
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide la longueur et le type de chaque position d'un tableau utilisé comme tuple.
--
-- Règles appliquées
-- -----------------
--   1. La liste des types attendus définit la longueur du tuple.
--   2. Chaque position est comparée avec type::of().
--   3. Les types attendus sont normalisés en minuscules.
--   4. L'ordre des types est significatif.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_types: array<string>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TUPLE_LENGTH
-- <FIELD>_INVALID_TUPLE_ITEM_TYPE
-- VALIDATION_EMPTY_TUPLE_TYPES
-- VALIDATION_INVALID_TUPLE_TYPE_NAME
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
--   - string::lowercase()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::of()
--   - array::len()
--   - array::map()
--   - array::any()
--   - array::all()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_tuple_types(
    $value: option<any>,
    $field: string,
    $expected_types: array<string>
) -> array {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF array::len($expected_types) = 0 {
        THROW "VALIDATION_EMPTY_TUPLE_TYPES";
    };

    LET $clean_expected_types = array::map(
        $expected_types,
        |$type_name| string::lowercase(string::trim($type_name))
    );

    IF array::any(
        $clean_expected_types,
        |$type_name| $type_name = ""
    ) {
        THROW "VALIDATION_INVALID_TUPLE_TYPE_NAME";
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

    IF array::len($value) != array::len($clean_expected_types) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TUPLE_LENGTH"
        );
    };

    LET $indexes = 0..array::len($value);

    LET $all_types_match = array::all(
        $indexes,
        |$index|
            string::lowercase(type::of($value[$index]))
            = $clean_expected_types[$index]
    );

    IF !$all_types_match {
        THROW string::concat(
            $clean_field,
            "_INVALID_TUPLE_ITEM_TYPE"
        );
    };

    RETURN $value;
}
COMMENT "
Valide la longueur et le type exact de chaque position d'un tuple représenté
par un tableau.
"
PERMISSIONS FULL;
