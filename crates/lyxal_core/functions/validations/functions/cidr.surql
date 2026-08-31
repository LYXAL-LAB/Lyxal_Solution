-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/cidr.surql
-- Fonction     : fn::validation_cidr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un réseau CIDR IPv4 ou IPv6.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit contenir une adresse et un préfixe séparés par '/'.
--   2. Le préfixe IPv4 doit être compris entre 0 et 32.
--   3. Le préfixe IPv6 doit être compris entre 0 et 128.
--   4. Au moins une famille IP doit être autorisée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_ipv4: bool
-- $allow_ipv6: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_CIDR
-- <FIELD>_CIDR_FAMILY_NOT_ALLOWED
-- VALIDATION_NO_CIDR_FAMILY_ALLOWED
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
--   - string::split()
--   - string::is_ipv4()
--   - string::is_ipv6()
--   - string::is_numeric()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_cidr(
    $value: option<any>,
    $field: string,
    $allow_ipv4: bool,
    $allow_ipv6: bool
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

    IF !$allow_ipv4 AND !$allow_ipv6 {
        THROW "VALIDATION_NO_CIDR_FAMILY_ALLOWED";
    };

    LET $parts = string::split($clean_value, "/");

    IF array::len($parts) != 2
        OR !string::is_numeric($parts[1])
    {
        THROW string::concat($clean_field, "_INVALID_CIDR");
    };

    LET $address = $parts[0];
    LET $prefix = <int>$parts[1];
    LET $is_v4 = string::is_ipv4($address);
    LET $is_v6 = string::is_ipv6($address);

    IF !$is_v4 AND !$is_v6 {
        THROW string::concat($clean_field, "_INVALID_CIDR");
    };

    IF ($is_v4 AND !$allow_ipv4)
        OR ($is_v6 AND !$allow_ipv6)
    {
        THROW string::concat($clean_field, "_CIDR_FAMILY_NOT_ALLOWED");
    };

    IF ($is_v4 AND ($prefix < 0 OR $prefix > 32))
        OR ($is_v6 AND ($prefix < 0 OR $prefix > 128))
    {
        THROW string::concat($clean_field, "_INVALID_CIDR");
    };

    RETURN string::lowercase($clean_value);
}
COMMENT "
Valide lexicalement un réseau CIDR IPv4 ou IPv6.
"
PERMISSIONS FULL;
