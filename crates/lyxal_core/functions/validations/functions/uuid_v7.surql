-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/uuid_v7.surql
-- Fonction     : fn::validation_uuid_v7
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un UUID v7 typé ou textuel et retourne sa représentation d'origine.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_string: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_UUID_V7
-- <FIELD>_STRING_UUID_NOT_ALLOWED
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
--   - string::matches()
--   - string::lowercase()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - type::is_uuid()
--   - type::string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_uuid_v7(
    $value: option<any>,
    $field: string,
    $allow_string: bool
) -> any {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF type::is_string($value) AND !$allow_string {
        THROW string::concat(
            $clean_field,
            "_STRING_UUID_NOT_ALLOWED"
        );
    };

    IF !type::is_uuid($value) AND !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $uuid_text = string::lowercase(type::string($value));

    IF !string::matches(
        $uuid_text,
        "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    ) {
        THROW string::concat($clean_field, "_INVALID_UUID_V7");
    };

    RETURN $value;
}
COMMENT "
Valide qu'un UUID typé ou textuel respecte la structure de la version 7.
"
PERMISSIONS FULL;
