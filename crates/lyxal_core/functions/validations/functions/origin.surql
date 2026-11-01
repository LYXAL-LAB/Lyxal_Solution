-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/origin.surql
-- Fonction : fn::validation_origin
--
-- Valide une origine HTTP(S) (schéma://hôte[:port], sans chemin), selon les
-- schémas autorisés et l'autorisation d'un port explicite. La valeur
-- renvoyée est en minuscules.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $allow_http  : bool — accepter http://
--   $allow_https : bool — accepter https://
--   $allow_port  : bool — accepter un port explicite
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'origine en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : aucun schéma autorisé
--
-- Exemple (dans une fonction de module)
--   LET $origin = fn::validation_origin($headers.origin, false, true, true);
--   IF !$origin.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $origin.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_origin(
    $value: any,
    $allow_http: bool,
    $allow_https: bool,
    $allow_port: bool
) -> object {
    IF !$allow_http AND !$allow_https { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $is_http = string::starts_with($clean, "http://");
    LET $is_https = string::starts_with($clean, "https://");
    IF (!$is_http AND !$is_https) OR !string::is_url($clean) OR string::matches($clean, "^https?://[^/?#]+[/?#].*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "origin" } };
    };
    IF ($is_http AND !$allow_http) OR ($is_https AND !$allow_https) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "scheme" } };
    };
    IF !$allow_port AND string::matches($clean, "^https?://(\\[[^\\]]+\\]|[^:]+):[0-9]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "port" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une origine HTTP(S) (schéma://hôte[:port], sans chemin), selon les schémas autorisés et l'autorisation d'un port explicite. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
