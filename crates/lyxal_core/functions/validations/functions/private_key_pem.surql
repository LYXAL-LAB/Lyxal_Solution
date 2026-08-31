-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/private_key_pem.surql
-- Fonction     : fn::validation_private_key_pem
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un bloc PEM de clé privée PKCS#8, RSA, EC ou chiffrée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_encrypted: bool
-- $max_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_PRIVATE_KEY_PEM
-- <FIELD>_ENCRYPTED_KEY_NOT_ALLOWED
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_PEM_MAX_LENGTH
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
--   - string::starts_with()
--   - string::ends_with()
--   - string::contains()
--   - string::len()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_private_key_pem(
    $value: option<any>,
    $field: string,
    $allow_encrypted: bool,
    $max_length: int
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

    IF $max_length < 1 {
        THROW "VALIDATION_INVALID_PEM_MAX_LENGTH";
    };

    IF string::len($clean_value) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    LET $is_encrypted =
        string::starts_with(
            $clean_value,
            "-----BEGIN ENCRYPTED PRIVATE KEY-----"
        )
        AND string::ends_with(
            $clean_value,
            "-----END ENCRYPTED PRIVATE KEY-----"
        );

    IF $is_encrypted AND !$allow_encrypted {
        THROW string::concat(
            $clean_field,
            "_ENCRYPTED_KEY_NOT_ALLOWED"
        );
    };

    LET $is_supported =
        $is_encrypted
        OR (
            string::starts_with(
                $clean_value,
                "-----BEGIN PRIVATE KEY-----"
            )
            AND string::ends_with(
                $clean_value,
                "-----END PRIVATE KEY-----"
            )
        )
        OR (
            string::starts_with(
                $clean_value,
                "-----BEGIN RSA PRIVATE KEY-----"
            )
            AND string::ends_with(
                $clean_value,
                "-----END RSA PRIVATE KEY-----"
            )
        )
        OR (
            string::starts_with(
                $clean_value,
                "-----BEGIN EC PRIVATE KEY-----"
            )
            AND string::ends_with(
                $clean_value,
                "-----END EC PRIVATE KEY-----"
            )
        );

    IF !$is_supported
        OR !string::contains($clean_value, "
")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_PRIVATE_KEY_PEM"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide lexicalement un bloc PEM de clé privée prise en charge.
"
PERMISSIONS FULL;
