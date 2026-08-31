-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/time_string.surql
-- Fonction     : fn::validation_time_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une heure textuelle sur 24 heures, au format HH:MM ou HH:MM:SS.
--
-- Règles appliquées
-- -----------------
--   1. Les heures vont de 00 à 23.
--   2. Les minutes et secondes vont de 00 à 59.
--   3. Les secondes peuvent être obligatoires ou interdites selon la configuration.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $require_seconds: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_TIME_STRING
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
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_string(
    $value: option<any>,
    $field: string,
    $require_seconds: bool
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

    LET $pattern = IF $require_seconds {
        "^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"
    } ELSE {
        "^([01][0-9]|2[0-3]):[0-5][0-9]$"
    };

    IF !string::matches($clean_value, $pattern) {
        THROW string::concat($clean_field, "_INVALID_TIME_STRING");
    };

    RETURN $clean_value;
}
COMMENT "
Valide une heure textuelle 24 heures au format HH:MM ou HH:MM:SS.
"
PERMISSIONS FULL;
