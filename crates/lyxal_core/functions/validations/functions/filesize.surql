-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/filesize.surql
-- Fonction     : fn::validation_filesize
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une taille de fichier exprimée en octets sous forme d'entier non négatif.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_bytes: option<int>
-- $max_bytes: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SMALL
-- <FIELD>_TOO_LARGE
-- VALIDATION_INVALID_FILESIZE_RANGE
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
--   - string::concat()
--   - type::is_null()
--   - type::is_int()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_filesize(
    $value: option<any>,
    $field: string,
    $min_bytes: option<int>,
    $max_bytes: option<int>
) -> int {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_bytes IS NOT NONE AND $min_bytes < 0 {
        THROW "VALIDATION_INVALID_FILESIZE_RANGE";
    };

    IF $max_bytes IS NOT NONE AND $max_bytes < 0 {
        THROW "VALIDATION_INVALID_FILESIZE_RANGE";
    };

    IF $min_bytes IS NOT NONE
        AND $max_bytes IS NOT NONE
        AND $min_bytes > $max_bytes
    {
        THROW "VALIDATION_INVALID_FILESIZE_RANGE";
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

    IF $value < 0 {
        THROW string::concat($clean_field, "_TOO_SMALL");
    };

    IF $min_bytes IS NOT NONE AND $value < $min_bytes {
        THROW string::concat($clean_field, "_TOO_SMALL");
    };

    IF $max_bytes IS NOT NONE AND $value > $max_bytes {
        THROW string::concat($clean_field, "_TOO_LARGE");
    };

    RETURN $value;
}
COMMENT "
Valide une taille de fichier exprimée en octets dans une plage inclusive.
"
PERMISSIONS FULL;
