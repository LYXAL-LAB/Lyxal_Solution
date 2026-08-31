-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/weekday.surql
-- Fonction     : fn::validation_weekday
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un numéro de jour de semaine selon la convention ISO : lundi = 1, dimanche = 7.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un entier entre 1 et 7.
--   2. Une liste facultative peut limiter les jours autorisés.
--   3. La fonction utilise la convention ISO 8601.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_days: option<array<int>>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_WEEKDAY
-- <FIELD>_WEEKDAY_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_WEEKDAYS
-- VALIDATION_INVALID_ALLOWED_WEEKDAY
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
--   - array::len()
--   - array::any()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_weekday(
    $value: option<any>,
    $field: string,
    $allowed_days: option<array<int>>
) -> int {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $allowed_days IS NOT NONE {
        IF array::len($allowed_days) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_WEEKDAYS";
        };

        IF array::any($allowed_days, |$day| $day < 1 OR $day > 7) {
            THROW "VALIDATION_INVALID_ALLOWED_WEEKDAY";
        };
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

    IF $value < 1 OR $value > 7 {
        THROW string::concat($clean_field, "_INVALID_WEEKDAY");
    };

    IF $allowed_days IS NOT NONE
        AND !array::contains($allowed_days, $value)
    {
        THROW string::concat($clean_field, "_WEEKDAY_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide un jour ISO de semaine compris entre 1, lundi, et 7, dimanche.
"
PERMISSIONS FULL;
