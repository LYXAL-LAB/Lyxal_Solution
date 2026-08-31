-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/object_no_none.surql
-- Fonction     : fn::validation_object_no_none
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'un objet ne contient aucune valeur NONE au premier niveau.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un objet.
--   2. Les valeurs directes sont inspectées avec object::values().
--   3. Le contrôle ne descend pas récursivement dans les objets imbriqués.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_NONE_VALUE_NOT_ALLOWED
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
--   - type::is_none()
--   - type::is_object()
--   - object::values()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_no_none(
    $value: option<any>,
    $field: string
) -> object {
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

    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF array::any(
        object::values($value),
        |$item| type::is_none($item)
    ) {
        THROW string::concat(
            $clean_field,
            "_NONE_VALUE_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Valide qu'un objet ne contient aucune valeur NONE à son premier niveau.
"
PERMISSIONS FULL;
