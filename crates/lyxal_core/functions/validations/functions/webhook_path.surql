-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/webhook_path.surql
-- Fonction : fn::validation_webhook_path
--
-- Valide un chemin de webhook (/segment/…, segments [A-Za-z0-9._-]) ;
-- paramètres « :nom » et joker « * » acceptés seulement si autorisés.
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $allow_parameters : bool — accepter les segments « :nom »
--   $allow_wildcard   : bool — accepter le segment « * »
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $path = fn::validation_webhook_path($params.path, true, false);
--   IF !$path.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $path.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_webhook_path(
    $value: any,
    $allow_parameters: bool,
    $allow_wildcard: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !$allow_parameters AND string::contains($clean, ":") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "parameters" } };
    };
    IF !$allow_wildcard AND string::contains($clean, "*") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "wildcard" } };
    };
    IF !string::matches($clean, "^(/([A-Za-z0-9._-]+|:[A-Za-z_][A-Za-z0-9_]*|\\*))+$") OR string::contains($clean, "..") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "webhook_path" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un chemin de webhook (/segment/…, segments [A-Za-z0-9._-]) ; paramètres « :nom » et joker « * » acceptés seulement si autorisés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
