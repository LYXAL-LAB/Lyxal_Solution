-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/allowed_types.surql
-- Fonction     : fn::validation_allowed_types
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que le type réel d'une valeur appartient à une liste de types autorisés.
--
-- Règles appliquées
-- -----------------
--   1. La liste des types autorisés doit être non vide.
--   2. Chaque nom de type est nettoyé et normalisé en minuscules.
--   3. Le type réel est obtenu avec type::of().
--   4. La valeur d'origine est retournée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_types: array<string>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TYPE_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_TYPES
-- VALIDATION_INVALID_ALLOWED_TYPE
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
--   - type::of()
--   - array::len()
--   - array::map()
--   - array::any()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_allowed_types(
    $value: option<any>,
    $field: string,
    $allowed_types: array<string>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF array::len($allowed_types) = 0 {
        THROW "VALIDATION_EMPTY_ALLOWED_TYPES";
    };

    LET $clean_allowed_types = array::map(
        $allowed_types,
        |$type_name| string::lowercase(string::trim($type_name))
    );

    IF array::any(
        $clean_allowed_types,
        |$type_name| $type_name = ""
    ) {
        THROW "VALIDATION_INVALID_ALLOWED_TYPE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    LET $actual_type = string::lowercase(type::of($value));

    IF !array::contains($clean_allowed_types, $actual_type) {
        THROW string::concat($clean_field, "_TYPE_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide que le type réel d'une valeur appartient à une liste de types SurrealDB
autorisés.
"
PERMISSIONS FULL;
