-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_storage_path.surql
-- Fonction     : fn::validation_lyxal_storage_path
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un chemin logique de ressource Lyxal organisé par segments.
--
-- Règles appliquées
-- -----------------
--   1. Le chemin est relatif et ne commence pas par un slash.
--   2. Les segments utilisent lettres, chiffres, points, tirets et tirets bas.
--   3. Les traversées de répertoires et doubles slashs sont interdits.
--   4. Une racine logique peut être imposée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $required_root: option<string>
-- $allow_file_extension: bool
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_STORAGE_PATH
-- <FIELD>_STORAGE_ROOT_REQUIRED
-- <FIELD>_FILE_EXTENSION_NOT_ALLOWED
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
--   - aucune dépendance à l'authentification ;
--   - aucune création de ressource Lyxal ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_storage_path(
    $value: option<any>,
    $field: string,
    $required_root: option<string>,
    $allow_file_extension: bool,
    $max_length: int
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

    IF $max_length < 1 {
        THROW "VALIDATION_INVALID_STORAGE_PATH_MAX_LENGTH";
    };

    IF string::len($clean_value) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF string::starts_with($clean_value, "/")
        OR string::ends_with($clean_value, "/")
        OR string::contains($clean_value, "//")
        OR string::contains($clean_value, "..")
        OR string::contains($clean_value, "\")
        OR !string::matches(
            $clean_value,
            "^[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$"
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_STORAGE_PATH"
        );
    };

    IF !$allow_file_extension
        AND string::matches(
            $clean_value,
            "(?:^|/)[^/]+\.[A-Za-z0-9]+$"
        )
    {
        THROW string::concat(
            $clean_field,
            "_FILE_EXTENSION_NOT_ALLOWED"
        );
    };

    IF $required_root IS NOT NONE {
        LET $root = string::trim($required_root);

        IF $root = ""
            OR !string::starts_with(
                $clean_value,
                string::concat($root, "/")
            )
        {
            THROW string::concat(
                $clean_field,
                "_STORAGE_ROOT_REQUIRED"
            );
        };
    };

    RETURN $clean_value;
}
COMMENT "
Valide un chemin logique de ressource Lyxal avec racine facultativement imposée.
"
PERMISSIONS FULL;
