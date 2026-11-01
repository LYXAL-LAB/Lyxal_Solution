-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/totp_code.surql
-- Fonction : fn::validation_totp_code
--
-- Valide un code TOTP : exactement 6 ou 8 chiffres.
--
-- Paramètres
--   $value  : any — valeur à contrôler
--   $digits : int — nombre de chiffres : 6 ou 8
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
--   CORE_UNSUPPORTED_OPTION : $digits différent de 6 et 8
--
-- Exemple (dans une fonction de module)
--   LET $code = fn::validation_totp_code($params.code, 6);
--   IF !$code.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $code.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_totp_code(
    $value: any,
    $digits: int
) -> object {
    IF $digits NOT IN [6, 8] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF string::len($clean) != $digits OR !string::matches($clean, "^[0-9]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "totp_code", digits: $digits } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code TOTP : exactement 6 ou 8 chiffres. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
