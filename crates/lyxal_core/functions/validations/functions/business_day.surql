-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/business_day.surql
-- Fonction     : fn::validation_business_day
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une date civile à minuit UTC est un jour ouvré et n'appartient pas à une liste de jours fériés.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un datetime à minuit UTC.
--   2. Samedi et dimanche sont refusés.
--   3. Une liste facultative de jours fériés peut être fournie.
--   4. Les jours fériés doivent eux-mêmes être à minuit UTC.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $holidays: option<array<datetime>>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_DATE
-- <FIELD>_WEEKEND_NOT_ALLOWED
-- <FIELD>_HOLIDAY_NOT_ALLOWED
-- VALIDATION_INVALID_HOLIDAY_DATE
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
--   - time::format()
--   - array::any()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_business_day(
    $value: option<any>,
    $field: string,
    $holidays: option<array<datetime>>
) -> datetime {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $holidays IS NOT NONE
        AND array::any(
            $holidays,
            |$holiday| $holiday != time::floor($holiday, 1d)
        )
    {
        THROW "VALIDATION_INVALID_HOLIDAY_DATE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_datetime($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value != time::floor($value, 1d) {
        THROW string::concat($clean_field, "_INVALID_DATE");
    };

    LET $weekday = <int>time::format($value, "%w");

    IF $weekday = 0 OR $weekday = 6 {
        THROW string::concat($clean_field, "_WEEKEND_NOT_ALLOWED");
    };

    IF $holidays IS NOT NONE
        AND array::contains($holidays, $value)
    {
        THROW string::concat($clean_field, "_HOLIDAY_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide qu'une date civile à minuit UTC est un jour ouvré hors jours fériés.
"
PERMISSIONS FULL;
