-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/age_range.surql
-- Fonction     : fn::validation_age_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Calcule approximativement l'âge depuis une date de naissance et contrôle une plage.
--
-- Paramètres
-- ----------
-- $birthdate: option<any>
-- $field: string
-- $min_age: option<int>
-- $max_age: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_BIRTHDATE
-- <FIELD>_TOO_YOUNG
-- <FIELD>_TOO_OLD
-- VALIDATION_INVALID_AGE_RANGE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
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
--   - aucune consultation de registre externe ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

--
-- Précision
-- ---------
-- L'âge est calculé par différence d'années calendaires puis ajusté selon le
-- mois et le jour courants.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_age_range(
    $birthdate: option<any>,
    $field: string,
    $min_age: option<int>,
    $max_age: option<int>
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_age IS NOT NONE AND $min_age < 0 {
        THROW "VALIDATION_INVALID_AGE_RANGE";
    };

    IF $max_age IS NOT NONE AND $max_age < 0 {
        THROW "VALIDATION_INVALID_AGE_RANGE";
    };

    IF $min_age IS NOT NONE
        AND $max_age IS NOT NONE
        AND $min_age > $max_age
    {
        THROW "VALIDATION_INVALID_AGE_RANGE";
    };

    IF $birthdate IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($birthdate) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_datetime($birthdate)
        OR $birthdate != time::floor($birthdate, 1d)
    {
        THROW string::concat($clean_field, "_INVALID_BIRTHDATE");
    };

    LET $today = time::floor(time::now(), 1d);

    IF $birthdate > $today {
        THROW string::concat($clean_field, "_INVALID_BIRTHDATE");
    };

    LET $birth_year = <int>time::format($birthdate, "%Y");
    LET $birth_month_day = time::format($birthdate, "%m%d");
    LET $current_year = <int>time::format($today, "%Y");
    LET $current_month_day = time::format($today, "%m%d");

    LET $age = $current_year
        - $birth_year
        - IF $current_month_day < $birth_month_day { 1 } ELSE { 0 };

    IF $min_age IS NOT NONE AND $age < $min_age {
        THROW string::concat($clean_field, "_TOO_YOUNG");
    };

    IF $max_age IS NOT NONE AND $age > $max_age {
        THROW string::concat($clean_field, "_TOO_OLD");
    };

    RETURN {
        birthdate: $birthdate,
        age: $age
    };
}
COMMENT "
Calcule l'âge calendaire depuis une date de naissance et contrôle une plage.
"
PERMISSIONS FULL;
