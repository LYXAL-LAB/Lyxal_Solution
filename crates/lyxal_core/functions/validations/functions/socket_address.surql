-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/socket_address.surql
-- Fonction : fn::validation_socket_address
--
-- Valide une adresse de socket hôte:port (port 1 à 65535) ; l'hôte peut être
-- un nom d'hôte, une IPv4 ou une IPv6 entre crochets, selon les types
-- autorisés. La valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allow_hostname : bool — accepter un nom d'hôte
--   $allow_ipv4     : bool — accepter une IPv4
--   $allow_ipv6     : bool — accepter une IPv6 entre crochets ([::1]:443)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'adresse en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : aucun type d'hôte autorisé
--
-- Exemple (dans une fonction de module)
--   LET $address = fn::validation_socket_address($params.address, true, true, true);
--   IF !$address.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $address.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_socket_address(
    $value: any,
    $allow_hostname: bool,
    $allow_ipv4: bool,
    $allow_ipv6: bool
) -> object {
    IF !$allow_hostname AND !$allow_ipv4 AND !$allow_ipv6 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $bracketed = string::matches($clean, "^\\[[^\\]]+\\]:[0-9]{1,5}$");
    LET $plain = string::matches($clean, "^[^:\\[\\]]+:[0-9]{1,5}$");
    IF !$bracketed AND !$plain { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "socket_address" } }; };
    LET $separator = IF $bracketed { "]:" } ELSE { ":" };
    LET $host = IF $bracketed { string::slice(string::split($clean, $separator)[0], 1) } ELSE { string::split($clean, $separator)[0] };
    LET $port = <int> string::split($clean, $separator)[1];
    LET $kind = IF $bracketed AND string::is_ipv6($host) { "ipv6" }
        ELSE IF !$bracketed AND string::is_ipv4($host) { "ipv4" }
        ELSE IF !$bracketed AND string::matches($host, "^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$") { "hostname" }
        ELSE { NONE };
    IF $kind IS NONE OR $port < 1 OR $port > 65535 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "socket_address" } };
    };
    IF ($kind = "ipv6" AND !$allow_ipv6) OR ($kind = "ipv4" AND !$allow_ipv4) OR ($kind = "hostname" AND !$allow_hostname) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: $kind } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une adresse de socket hôte:port (port 1 à 65535) ; l'hôte peut être un nom d'hôte, une IPv4 ou une IPv6 entre crochets, selon les types autorisés. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
