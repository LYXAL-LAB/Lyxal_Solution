-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/http_url.surql
-- Fonction : fn::validation_http_url
--
-- Valide une URL http:// ou https://, selon les schémas autorisés.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $allow_http  : bool — accepter http://
--   $allow_https : bool — accepter https://
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
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
--   LET $callback = fn::validation_http_url($params.callback_url, false, true);
--   IF !$callback.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $callback.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_http_url(
    $value: any,
    $allow_http: bool,
    $allow_https: bool
) -> object {
    IF !$allow_http AND !$allow_https { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $is_http = string::starts_with(string::lowercase($clean), "http://");
    LET $is_https = string::starts_with(string::lowercase($clean), "https://");
    IF (!$is_http AND !$is_https) OR !string::is_url($clean) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "http_url" } };
    };
    IF ($is_http AND !$allow_http) OR ($is_https AND !$allow_https) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "scheme" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une URL http:// ou https://, selon les schémas autorisés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
