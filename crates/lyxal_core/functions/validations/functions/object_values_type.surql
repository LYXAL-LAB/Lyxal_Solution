-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/object_values_type.surql
-- Fonction     : fn::validation_object_values_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que toutes les valeurs d'un objet possèdent exactement le même type attendu.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un objet.
--   2. Les objets vides peuvent être autorisés ou refusés.
--   3. Chaque valeur est comparée au type attendu via type::of().
--   4. Les clés ne sont pas modifiées.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_type: string
-- $allow_empty: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_EMPTY_NOT_ALLOWED
-- <FIELD>_INVALID_OBJECT_VALUE_TYPE
-- VALIDATION_INVALID_EXPECTED_OBJECT_VALUE_TYPE
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
--   - type::is_object()
--   - type::of()
--   - object::is_empty()
--   - object::values()
--   - array::all()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_values_type(
    $value: option<any>,
    $field: string,
    $expected_type: string,
    $allow_empty: bool
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $clean_expected_type = string::lowercase(
        string::trim($expected_type)
    );

    IF $clean_expected_type = "" {
        THROW "VALIDATION_INVALID_EXPECTED_OBJECT_VALUE_TYPE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !$allow_empty AND object::is_empty($value) {
        THROW string::concat($clean_field, "_EMPTY_NOT_ALLOWED");
    };

    IF !array::all(
        object::values($value),
        |$item|
            string::lowercase(type::of($item))
            = $clean_expected_type
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_OBJECT_VALUE_TYPE"
        );
    };

    RETURN $value;
}
COMMENT "
Valide que toutes les valeurs d'un objet possèdent le type SurrealDB attendu.
"
PERMISSIONS FULL;
