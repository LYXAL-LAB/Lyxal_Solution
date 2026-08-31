-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/socket_address.surql
-- Fonction     : fn::validation_socket_address
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une adresse socket textuelle composée d'un hôte et d'un port.
--
-- Règles appliquées
-- -----------------
--   1. IPv4 et hostname utilisent la forme host:port.
--   2. IPv6 utilise obligatoirement la forme [adresse]:port.
--   3. Le port doit être compris entre 1 et 65535.
--   4. La fonction ne réalise aucune résolution DNS.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_hostname: bool
-- $allow_ipv4: bool
-- $allow_ipv6: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_SOCKET_ADDRESS
-- <FIELD>_SOCKET_HOST_NOT_ALLOWED
-- VALIDATION_NO_SOCKET_HOST_TYPE_ALLOWED
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
--   - string::matches()
--   - string::slice()
--   - string::split()
--   - string::is_ipv4()
--   - string::is_ipv6()
--   - string::is_domain()
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

DEFINE FUNCTION OVERWRITE fn::validation_socket_address(
    $value: option<any>,
    $field: string,
    $allow_hostname: bool,
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

    IF !$allow_hostname AND !$allow_ipv4 AND !$allow_ipv6 {
        THROW "VALIDATION_NO_SOCKET_HOST_TYPE_ALLOWED";
    };

    LET $is_bracketed_ipv6 = string::matches(
        $clean_value,
        "^\[[^\]]+\]:[0-9]+$"
    );

    IF $is_bracketed_ipv6 {
        LET $end_bracket_parts = string::split($clean_value, "]:");
        LET $host_with_bracket = $end_bracket_parts[0];
        LET $host = string::slice(
            $host_with_bracket,
            1,
            string::len($host_with_bracket) - 1
        );
        LET $port_string = $end_bracket_parts[1];

        IF !$allow_ipv6
            OR !string::is_ipv6($host)
            OR !string::is_numeric($port_string)
        {
            THROW string::concat(
                $clean_field,
                "_SOCKET_HOST_NOT_ALLOWED"
            );
        };

        LET $port = <int>$port_string;

        IF $port < 1 OR $port > 65535 {
            THROW string::concat(
                $clean_field,
                "_INVALID_SOCKET_ADDRESS"
            );
        };

        RETURN string::lowercase($clean_value);
    };

    LET $parts = string::split($clean_value, ":");

    IF array::len($parts) != 2
        OR !string::is_numeric($parts[1])
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_SOCKET_ADDRESS"
        );
    };

    LET $host = $parts[0];
    LET $port = <int>$parts[1];
    LET $valid_host =
        ($allow_ipv4 AND string::is_ipv4($host))
        OR ($allow_hostname AND string::is_domain($host))
        OR ($allow_hostname AND string::matches(
            $host,
            "^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$"
        ));

    IF !$valid_host {
        THROW string::concat(
            $clean_field,
            "_SOCKET_HOST_NOT_ALLOWED"
        );
    };

    IF $port < 1 OR $port > 65535 {
        THROW string::concat(
            $clean_field,
            "_INVALID_SOCKET_ADDRESS"
        );
    };

    RETURN string::lowercase($clean_value);
}
COMMENT "
Valide une adresse socket hostname:port, IPv4:port ou [IPv6]:port.
"
PERMISSIONS FULL;
