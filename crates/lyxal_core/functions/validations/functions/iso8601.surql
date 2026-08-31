-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/iso8601.surql
-- Fonction     : fn::validation_iso8601
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne datetime ISO 8601/RFC 3339 contenant obligatoirement une heure et un fuseau.
--
-- Règles appliquées
-- -----------------
--   1. La date et l'heure sont obligatoires.
--   2. Le suffixe Z ou un décalage ±HH:MM est obligatoire.
--   3. Les fractions de seconde peuvent être autorisées ou interdites.
--   4. La date doit être interprétable par SurrealDB.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_fractional_seconds: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_ISO8601
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
--   - string::is_datetime()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_iso8601(
    $value: option<any>,
    $field: string,
    $allow_fractional_seconds: bool
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

    LET $pattern = IF $allow_fractional_seconds {
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})$"
    } ELSE {
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$"
    };

    IF !string::matches($clean_value, $pattern)
        OR !string::is_datetime($clean_value)
    {
        THROW string::concat($clean_field, "_INVALID_ISO8601");
    };

    RETURN $clean_value;
}
COMMENT "
Valide une chaîne ISO 8601/RFC 3339 avec date, heure et fuseau obligatoires.
"
PERMISSIONS FULL;
