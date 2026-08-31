-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/ulid.surql
-- Fonction     : fn::validation_ulid
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un ULID textuel avec le validateur natif SurrealDB.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_ULID
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
-- Primitive pure : aucune lecture ou écriture persistante, aucun appel réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::uppercase()
--   - string::is_ulid()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ulid(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

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

    LET $ulid = string::uppercase($clean_value);

    IF !string::is_ulid($ulid) {
        THROW string::concat($clean_field, "_INVALID_ULID");
    };

    RETURN $ulid;
}
COMMENT "
Valide un ULID textuel et le normalise en majuscules.
"
PERMISSIONS FULL;
