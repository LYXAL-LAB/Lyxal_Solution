-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/ip.surql
-- Fonction : fn::validation_ip
--
-- Valide une adresse IP, de version quelconque ou imposée ("ipv4" ou
-- "ipv6").
--
-- Paramètres
--   $value   : any — valeur à contrôler
--   $version : option<string> — "ipv4", "ipv6" ou NONE pour les deux
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : version inconnue
--
-- Exemple (dans une fonction de module)
--   LET $ip = fn::validation_ip($params.ip, NONE);
--   IF !$ip.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $ip.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ip(
    $value: any,
    $version: option<string>
) -> object {
    LET $family = IF $version IS NONE { "any" } ELSE { string::lowercase(string::trim($version)) };
    IF $family NOT IN ["any", "ipv4", "ipv6"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF ($family = "any" AND !string::is_ip($clean)) OR ($family = "ipv4" AND !string::is_ipv4($clean)) OR ($family = "ipv6" AND !string::is_ipv6($clean)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: IF $family = "any" { "ip" } ELSE { $family } } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une adresse IP, de version quelconque ou imposée (\"ipv4\" ou \"ipv6\"). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
