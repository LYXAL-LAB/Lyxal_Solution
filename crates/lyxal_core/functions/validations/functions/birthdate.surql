-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/birthdate.surql
-- Fonction     : fn::validation_birthdate
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une date de naissance typée datetime à minuit UTC.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_today: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_BIRTHDATE
-- <FIELD>_FUTURE_BIRTHDATE_NOT_ALLOWED
-- <FIELD>_TODAY_NOT_ALLOWED
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

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_birthdate(
    $value: option<any>,
    $field: string,
    $allow_today: bool
) -> datetime {
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

    IF !type::is_datetime($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value != time::floor($value, 1d) {
        THROW string::concat($clean_field, "_INVALID_BIRTHDATE");
    };

    LET $today = time::floor(time::now(), 1d);

    IF $value > $today {
        THROW string::concat(
            $clean_field,
            "_FUTURE_BIRTHDATE_NOT_ALLOWED"
        );
    };

    IF !$allow_today AND $value = $today {
        THROW string::concat($clean_field, "_TODAY_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide une date de naissance à minuit UTC et refuse les dates futures.
"
PERMISSIONS FULL;
