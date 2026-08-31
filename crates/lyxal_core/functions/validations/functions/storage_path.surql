-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/storage_path.surql
-- Fonction     : fn::validation_storage_path
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un chemin logique relatif destiné à un stockage objet ou à Bunny Storage.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_leading_slash: bool
-- $allow_trailing_slash: bool
-- $max_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_STORAGE_PATH
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_STORAGE_PATH_MAX_LENGTH
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
--   - aucun accès réseau ;
--   - aucune inspection binaire réelle du fichier ;
--   - aucune conversion implicite de la valeur validée.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::starts_with()
--   - string::ends_with()
--   - string::contains()
--   - string::matches()
--   - string::len()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_storage_path(
    $value: option<any>,
    $field: string,
    $allow_leading_slash: bool,
    $allow_trailing_slash: bool,
    $max_length: int
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $max_length < 1 {
        THROW "VALIDATION_INVALID_STORAGE_PATH_MAX_LENGTH";
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

    IF string::len($clean_value) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF (!$allow_leading_slash AND string::starts_with($clean_value, "/"))
        OR (!$allow_trailing_slash AND string::ends_with($clean_value, "/"))
        OR string::contains($clean_value, "//")
        OR string::contains($clean_value, "..")
        OR string::contains($clean_value, "\")
        OR !string::matches(
            $clean_value,
            "^/?[A-Za-z0-9._~/-]+/?$"
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_STORAGE_PATH"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un chemin relatif sûr pour un stockage objet.
"
PERMISSIONS FULL;
