-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/timezone.surql
-- Fonction     : fn::validation_timezone
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un identifiant de fuseau horaire IANA ou la valeur UTC.
--
-- Règles appliquées
-- -----------------
--   1. UTC peut être autorisé explicitement.
--   2. Les autres valeurs doivent suivre la forme Area/Location.
--   3. Plusieurs segments sont autorisés.
--   4. La fonction ne consulte pas la base IANA et ne garantit pas que le fuseau existe.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_utc: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_TIMEZONE
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

DEFINE FUNCTION OVERWRITE fn::validation_timezone(
    $value: option<any>,
    $field: string,
    $allow_utc: bool
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

    IF $allow_utc AND $clean_value = "UTC" {
        RETURN $clean_value;
    };

    IF !string::matches(
        $clean_value,
        "^[A-Za-z]+(?:[._+-][A-Za-z0-9]+)*/[A-Za-z0-9]+(?:[._+-][A-Za-z0-9]+)*(?:/[A-Za-z0-9]+(?:[._+-][A-Za-z0-9]+)*)*$"
    ) {
        THROW string::concat($clean_field, "_INVALID_TIMEZONE");
    };

    RETURN $clean_value;
}
COMMENT "
Valide lexicalement un nom de fuseau IANA de forme Area/Location ou UTC.
"
PERMISSIONS FULL;
