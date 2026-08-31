-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/date_string.surql
-- Fonction     : fn::validation_date_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une date civile textuelle au format strict YYYY-MM-DD.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être une chaîne non vide.
--   2. Le format exact doit être %Y-%m-%d.
--   3. La date doit exister dans le calendrier grégorien.
--   4. La chaîne nettoyée est retournée sans conversion.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_DATE_STRING
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
-- Cette fonction est une primitive pure. Elle ne consulte ni ne modifie
-- aucune donnée persistante et ne contacte aucun service externe.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::is_datetime()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_date_string(
    $value: option<any>,
    $field: string
) -> string {
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

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF !string::is_datetime($clean_value, "%Y-%m-%d") {
        THROW string::concat($clean_field, "_INVALID_DATE_STRING");
    };

    RETURN $clean_value;
}
COMMENT "
Valide une date civile textuelle au format strict YYYY-MM-DD.
"
PERMISSIONS FULL;
