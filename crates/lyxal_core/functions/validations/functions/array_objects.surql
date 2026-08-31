-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_objects.surql
-- Fonction     : fn::validation_array_objects
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que tous les éléments d'un tableau sont des objets, avec objets vides facultativement interdits.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un tableau.
--   2. Chaque élément doit être strictement de type object.
--   3. Les objets vides peuvent être autorisés ou refusés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_empty_objects: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_OBJECT_ITEM
-- <FIELD>_EMPTY_OBJECT_ITEM_NOT_ALLOWED
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
--   - type::is_object()
--   - object::is_empty()
--   - array::all()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_objects(
    $value: option<any>,
    $field: string,
    $allow_empty_objects: bool
) -> array<object> {
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

    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !array::all($value, |$item| type::is_object($item)) {
        THROW string::concat(
            $clean_field,
            "_INVALID_OBJECT_ITEM"
        );
    };

    IF !$allow_empty_objects
        AND array::any(
            $value,
            |$item| object::is_empty($item)
        )
    {
        THROW string::concat(
            $clean_field,
            "_EMPTY_OBJECT_ITEM_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Valide que tous les éléments d'un tableau sont des objets.
"
PERMISSIONS FULL;
