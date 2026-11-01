-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/cidr.surql
-- Fonction : fn::validation_cidr
--
-- Valide une plage CIDR (adresse/préfixe) IPv4 (préfixe 0 à 32) ou IPv6 (0 à
-- 128), selon les familles autorisées. La valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $allow_ipv4 : bool — accepter une plage IPv4
--   $allow_ipv6 : bool — accepter une plage IPv6
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la plage en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : aucune famille autorisée
--
-- Exemple (dans une fonction de module)
--   LET $range = fn::validation_cidr($params.range, true, true);
--   IF !$range.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $range.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_cidr(
    $value: any,
    $allow_ipv4: bool,
    $allow_ipv6: bool
) -> object {
    IF !$allow_ipv4 AND !$allow_ipv6 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $parts = string::split($clean, "/");
    IF array::len($parts) != 2 OR !string::matches($parts[1], "^[0-9]{1,3}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cidr" } }; };
    LET $is_v4 = string::is_ipv4($parts[0]);
    LET $is_v6 = string::is_ipv6($parts[0]);
    LET $prefix = <int> $parts[1];
    IF (!$is_v4 AND !$is_v6) OR ($is_v4 AND $prefix > 32) OR ($is_v6 AND $prefix > 128) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cidr" } };
    };
    IF ($is_v4 AND !$allow_ipv4) OR ($is_v6 AND !$allow_ipv6) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: IF $is_v4 { "ipv4" } ELSE { "ipv6" } } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une plage CIDR (adresse/préfixe) IPv4 (préfixe 0 à 32) ou IPv6 (0 à 128), selon les familles autorisées. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
