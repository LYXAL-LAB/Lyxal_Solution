-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/domain.surql
-- Fonction : fn::validation_domain
--
-- Valide un nom de domaine (string::is_domain) ; un sous-domaine est accepté
-- seulement si autorisé. La valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $allow_subdomains : bool — true pour accepter plus de deux labels (ex. api.example.com)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le domaine en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Exemple (dans une fonction de module)
--   LET $domain = fn::validation_domain($params.domain, true);
--   IF !$domain.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $domain.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_domain(
    $value: any,
    $allow_subdomains: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::is_domain($clean) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "domain" } };
    };
    IF !$allow_subdomains AND array::len(string::split($clean, ".")) != 2 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "subdomain" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de domaine (string::is_domain) ; un sous-domaine est accepté seulement si autorisé. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
