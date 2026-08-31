-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/date_range.surql
-- Fonction     : fn::validation_date_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une plage de dates civiles représentées par des datetimes à minuit UTC.
--
-- Règles appliquées
-- -----------------
--   1. Les deux valeurs doivent être des datetimes à minuit UTC.
--   2. La fin ne peut pas précéder le début.
--   3. Une plage d'un seul jour peut être autorisée ou refusée.
--   4. La durée en jours peut être encadrée.
--
-- Paramètres
-- ----------
-- $start_value: option<any>
-- $end_value: option<any>
-- $field: string
-- $allow_same_day: bool
-- $min_days: option<int>
-- $max_days: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_START_REQUIRED / _START_NULL_NOT_ALLOWED / _START_INVALID_TYPE / _START_INVALID_DATE
-- <FIELD>_END_REQUIRED / _END_NULL_NOT_ALLOWED / _END_INVALID_TYPE / _END_INVALID_DATE
-- <FIELD>_INVALID_ORDER
-- <FIELD>_SAME_DAY_NOT_ALLOWED
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_DATE_RANGE_DAYS
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
--   - type::is_datetime()
--   - time::floor()
--   - duration::days()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_date_range(
    $start_value: option<any>,
    $end_value: option<any>,
    $field: string,
    $allow_same_day: bool,
    $min_days: option<int>,
    $max_days: option<int>
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_days IS NOT NONE AND $min_days < 0 {
        THROW "VALIDATION_INVALID_DATE_RANGE_DAYS";
    };

    IF $max_days IS NOT NONE AND $max_days < 0 {
        THROW "VALIDATION_INVALID_DATE_RANGE_DAYS";
    };

    IF $min_days IS NOT NONE
        AND $max_days IS NOT NONE
        AND $min_days > $max_days
    {
        THROW "VALIDATION_INVALID_DATE_RANGE_DAYS";
    };

    IF $start_value IS NONE {
        THROW string::concat($clean_field, "_START_REQUIRED");
    };

    IF type::is_null($start_value) {
        THROW string::concat($clean_field, "_START_NULL_NOT_ALLOWED");
    };

    IF !type::is_datetime($start_value) {
        THROW string::concat($clean_field, "_START_INVALID_TYPE");
    };

    IF $start_value != time::floor($start_value, 1d) {
        THROW string::concat($clean_field, "_START_INVALID_DATE");
    };

    IF $end_value IS NONE {
        THROW string::concat($clean_field, "_END_REQUIRED");
    };

    IF type::is_null($end_value) {
        THROW string::concat($clean_field, "_END_NULL_NOT_ALLOWED");
    };

    IF !type::is_datetime($end_value) {
        THROW string::concat($clean_field, "_END_INVALID_TYPE");
    };

    IF $end_value != time::floor($end_value, 1d) {
        THROW string::concat($clean_field, "_END_INVALID_DATE");
    };

    IF $end_value < $start_value {
        THROW string::concat($clean_field, "_INVALID_ORDER");
    };

    IF !$allow_same_day AND $end_value = $start_value {
        THROW string::concat($clean_field, "_SAME_DAY_NOT_ALLOWED");
    };

    LET $days = duration::days($end_value - $start_value);

    IF $min_days IS NOT NONE AND $days < $min_days {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $max_days IS NOT NONE AND $days > $max_days {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    RETURN {
        start_date: $start_value,
        end_date: $end_value,
        days: $days
    };
}
COMMENT "
Valide une plage de dates civiles à minuit UTC et retourne son nombre de jours.
"
PERMISSIONS FULL;
