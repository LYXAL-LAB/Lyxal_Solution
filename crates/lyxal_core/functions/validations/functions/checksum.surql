-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/checksum.surql
-- Fonction     : fn::validation_checksum
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une somme de contrôle textuelle selon un algorithme déclaré.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $algorithm: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_CHECKSUM
-- <FIELD>_INVALID_CHECKSUM_LENGTH
-- VALIDATION_UNSUPPORTED_CHECKSUM_ALGORITHM
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
--   - string::lowercase()
--   - string::matches()
--   - string::len()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- Algorithmes pris en charge
-- --------------------------
-- crc32, md5, sha1, sha256, sha384 et sha512.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_checksum(
    $value: option<any>,
    $field: string,
    $algorithm: string
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $clean_algorithm = string::lowercase(
        string::trim($algorithm)
    );

    LET $expected_length = IF $clean_algorithm = "crc32" {
        8
    } ELSE IF $clean_algorithm = "md5" {
        32
    } ELSE IF $clean_algorithm = "sha1" {
        40
    } ELSE IF $clean_algorithm = "sha256" {
        64
    } ELSE IF $clean_algorithm = "sha384" {
        96
    } ELSE IF $clean_algorithm = "sha512" {
        128
    } ELSE {
        0
    };

    IF $expected_length = 0 {
        THROW "VALIDATION_UNSUPPORTED_CHECKSUM_ALGORITHM";
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

    IF !string::matches($clean_value, "^[0-9A-Fa-f]+$") {
        THROW string::concat($clean_field, "_INVALID_CHECKSUM");
    };

    IF string::len($clean_value) != $expected_length {
        THROW string::concat(
            $clean_field,
            "_INVALID_CHECKSUM_LENGTH"
        );
    };

    RETURN string::lowercase($clean_value);
}
COMMENT "
Valide une somme de contrôle hexadécimale selon l'algorithme déclaré.
"
PERMISSIONS FULL;
