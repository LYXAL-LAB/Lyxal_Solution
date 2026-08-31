-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/time_of_day_range.surql
-- Fonction     : fn::validation_time_of_day_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un créneau journalier exprimé en minutes depuis minuit, avec passage de minuit facultatif.
--
-- Règles appliquées
-- -----------------
--   1. Les bornes doivent être des entiers de 0 à 1439.
--   2. Sans passage de minuit, la fin doit suivre le début.
--   3. Avec passage de minuit, une fin plus petite représente le lendemain.
--   4. La durée calculée est comprise entre 0 et 1439 minutes.
--
-- Paramètres
-- ----------
-- $start_minute: option<any>
-- $end_minute: option<any>
-- $field: string
-- $allow_overnight: bool
-- $allow_zero_duration: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_START_REQUIRED / _START_NULL_NOT_ALLOWED / _START_INVALID_TYPE / _START_OUT_OF_RANGE
-- <FIELD>_END_REQUIRED / _END_NULL_NOT_ALLOWED / _END_INVALID_TYPE / _END_OUT_OF_RANGE
-- <FIELD>_INVALID_ORDER
-- <FIELD>_ZERO_DURATION_NOT_ALLOWED
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

DEFINE FUNCTION OVERWRITE fn::validation_time_of_day_range(
    $start_minute: option<any>,
    $end_minute: option<any>,
    $field: string,
    $allow_overnight: bool,
    $allow_zero_duration: bool
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $start_minute IS NONE {
        THROW string::concat($clean_field, "_START_REQUIRED");
    };

    IF type::is_null($start_minute) {
        THROW string::concat($clean_field, "_START_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($start_minute) {
        THROW string::concat($clean_field, "_START_INVALID_TYPE");
    };

    IF $start_minute < 0 OR $start_minute > 1439 {
        THROW string::concat($clean_field, "_START_OUT_OF_RANGE");
    };

    IF $end_minute IS NONE {
        THROW string::concat($clean_field, "_END_REQUIRED");
    };

    IF type::is_null($end_minute) {
        THROW string::concat($clean_field, "_END_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($end_minute) {
        THROW string::concat($clean_field, "_END_INVALID_TYPE");
    };

    IF $end_minute < 0 OR $end_minute > 1439 {
        THROW string::concat($clean_field, "_END_OUT_OF_RANGE");
    };

    IF !$allow_zero_duration AND $start_minute = $end_minute {
        THROW string::concat($clean_field, "_ZERO_DURATION_NOT_ALLOWED");
    };

    IF !$allow_overnight AND $end_minute < $start_minute {
        THROW string::concat($clean_field, "_INVALID_ORDER");
    };

    LET $duration_minutes = IF $end_minute >= $start_minute {
        $end_minute - $start_minute
    } ELSE {
        1440 - $start_minute + $end_minute
    };

    RETURN {
        start_minute: $start_minute,
        end_minute: $end_minute,
        duration_minutes: $duration_minutes,
        overnight: $end_minute < $start_minute
    };
}
COMMENT "
Valide un créneau journalier en minutes depuis minuit, avec nuit traversée
facultative.
"
PERMISSIONS FULL;
