-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/webhook_path.surql
-- Fonction     : fn::validation_webhook_path
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un chemin HTTP destiné à un webhook ou à une route interne.
--
-- Règles appliquées
-- -----------------
--   1. Le chemin doit commencer par '/'.
--   2. Les doubles barres et la traversée '..' sont interdites.
--   3. Les segments ordinaires utilisent lettres, chiffres, '_', '-' et '.'.
--   4. Les paramètres ':id' et le wildcard '*' peuvent être autorisés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_parameters: bool
-- $allow_wildcard: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_WEBHOOK_PATH
-- <FIELD>_PATH_PARAMETERS_NOT_ALLOWED
-- <FIELD>_WILDCARD_NOT_ALLOWED
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
-- Cette fonction est une primitive pure : aucune lecture ou écriture
-- persistante, aucun accès réseau et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::starts_with()
--   - string::contains()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_webhook_path(
    $value: option<any>,
    $field: string,
    $allow_parameters: bool,
    $allow_wildcard: bool
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

    IF !string::starts_with($clean_value, "/")
        OR string::contains($clean_value, "//")
        OR string::contains($clean_value, "..")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_WEBHOOK_PATH"
        );
    };

    IF !$allow_parameters
        AND string::contains($clean_value, ":")
    {
        THROW string::concat(
            $clean_field,
            "_PATH_PARAMETERS_NOT_ALLOWED"
        );
    };

    IF !$allow_wildcard
        AND string::contains($clean_value, "*")
    {
        THROW string::concat(
            $clean_field,
            "_WILDCARD_NOT_ALLOWED"
        );
    };

    LET $pattern = IF $allow_parameters AND $allow_wildcard {
        "^/(?:[A-Za-z0-9._-]+|:[A-Za-z_][A-Za-z0-9_]*|\*)(?:/(?:[A-Za-z0-9._-]+|:[A-Za-z_][A-Za-z0-9_]*|\*))*$"
    } ELSE IF $allow_parameters {
        "^/(?:[A-Za-z0-9._-]+|:[A-Za-z_][A-Za-z0-9_]*)(?:/(?:[A-Za-z0-9._-]+|:[A-Za-z_][A-Za-z0-9_]*))*$"
    } ELSE IF $allow_wildcard {
        "^/(?:[A-Za-z0-9._-]+|\*)(?:/(?:[A-Za-z0-9._-]+|\*))*$"
    } ELSE {
        "^/[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$"
    };

    IF !string::matches($clean_value, $pattern) {
        THROW string::concat(
            $clean_field,
            "_INVALID_WEBHOOK_PATH"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un chemin HTTP de webhook avec paramètres et wildcard facultatifs.
"
PERMISSIONS FULL;
