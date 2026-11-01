-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/base64.surql
-- Fonction : fn::validation_base64
--
-- Valide une chaîne Base64 (alphabet standard ou URL-safe), avec contrôle
-- facultatif du remplissage (longueur multiple de 4).
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $url_safe        : bool — true pour l'alphabet URL-safe (- et _), false pour l'alphabet standard (+ et /)
--   $require_padding : bool — true pour exiger une longueur multiple de 4
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
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_base64($params.content, false, true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_base64(
    $value: any,
    $url_safe: bool,
    $require_padding: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $pattern = IF $url_safe { "^[A-Za-z0-9_-]+={0,2}$" } ELSE { "^[A-Za-z0-9+/]+={0,2}$" };
    IF !string::matches($clean, $pattern) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "base64" } }; };
    IF $require_padding AND string::len($clean) % 4 != 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "base64_padding" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne Base64. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
