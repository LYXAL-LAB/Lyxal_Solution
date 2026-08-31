-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/time_of_day.surql
-- Fonction     : fn::validation_time_of_day
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une heure de journée exprimée en nombre entier de minutes depuis minuit.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un entier.
--   2. La plage autorisée est 0 à 1439.
--   3. 0 représente 00:00 et 1439 représente 23:59.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_OUT_OF_DAY_RANGE
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
--   - string::concat()
--   - type::is_null()
--   - type::is_int()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_of_day(
    $value: option<any>,
    $field: string
) -> int {
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

    IF !type::is_int($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value < 0 OR $value > 1439 {
        THROW string::concat($clean_field, "_OUT_OF_DAY_RANGE");
    };

    RETURN $value;
}
COMMENT "
Valide une heure de journée exprimée en minutes entières depuis minuit.
"
PERMISSIONS FULL;
