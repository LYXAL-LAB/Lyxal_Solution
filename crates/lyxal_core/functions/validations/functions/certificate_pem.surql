-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/certificate_pem.surql
-- Fonction     : fn::validation_certificate_pem
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un certificat X.509 encodé en PEM.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $max_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_CERTIFICATE_PEM
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

-- Limite
-- ------
-- La fonction ne vérifie ni la chaîne de confiance, ni l'expiration, ni la signature.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_certificate_pem(
    $value: option<any>,
    $field: string,
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

    IF !string::starts_with(
            $clean_value,
            "-----BEGIN CERTIFICATE-----"
        )
        OR !string::ends_with(
            $clean_value,
            "-----END CERTIFICATE-----"
        )
        OR !string::contains($clean_value, "
")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_CERTIFICATE_PEM"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide lexicalement un certificat X.509 encodé dans un bloc PEM.
"
PERMISSIONS FULL;
