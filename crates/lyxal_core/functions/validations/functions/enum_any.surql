-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/enum_any.surql
-- Fonction     : fn::validation_enum_any
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur scalaire ou structurée correspond exactement à une valeur autorisée.
--
-- Règles appliquées
-- -----------------
--   1. La liste des valeurs autorisées doit être non vide.
--   2. La comparaison est stricte selon l'égalité SurrealQL.
--   3. Aucune conversion ni normalisation n'est appliquée.
--   4. Cette fonction peut valider des valeurs non textuelles.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_values: array<any>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_VALUE_NOT_ALLOWED
-- VALIDATION_EMPTY_ENUM_VALUES
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
--   - array::len()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_enum_any(
    $value: option<any>,
    $field: string,
    $allowed_values: array<any>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF array::len($allowed_values) = 0 {
        THROW "VALIDATION_EMPTY_ENUM_VALUES";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !array::contains($allowed_values, $value) {
        THROW string::concat($clean_field, "_VALUE_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide qu'une valeur correspond exactement à l'une des valeurs autorisées.
"
PERMISSIONS FULL;
