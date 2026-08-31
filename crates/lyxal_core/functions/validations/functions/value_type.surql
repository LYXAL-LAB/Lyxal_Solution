-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/value_type.surql
-- Fonction     : fn::validation_value_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que le type réel d'une valeur correspond exactement au type attendu.
--
-- Règles appliquées
-- -----------------
--   1. Le nom du type attendu est obligatoire.
--   2. Le type réel est obtenu avec type::of().
--   3. La comparaison porte sur le nom exact retourné par SurrealDB.
--   4. La valeur d'origine est retournée sans conversion.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_type: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_UNEXPECTED_TYPE
-- VALIDATION_INVALID_EXPECTED_TYPE
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
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_value_type(
    $value: option<any>,
    $field: string,
    $expected_type: string
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $clean_expected_type = string::lowercase(
        string::trim($expected_type)
    );

    IF $clean_expected_type = "" {
        THROW "VALIDATION_INVALID_EXPECTED_TYPE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF string::lowercase(type::of($value)) != $clean_expected_type {
        THROW string::concat($clean_field, "_UNEXPECTED_TYPE");
    };

    RETURN $value;
}
COMMENT "
Valide qu'une valeur possède exactement le type SurrealDB attendu selon
type::of(), sans conversion implicite.
"
PERMISSIONS FULL;
