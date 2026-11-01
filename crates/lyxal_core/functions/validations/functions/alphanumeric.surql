-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/alphanumeric.surql
-- Fonction : fn::validation_alphanumeric
--
-- Valide qu'une chaîne non vide ne contient que des lettres et des chiffres
-- (string::is_alphanum).
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $trim_value : bool — true pour retirer les espaces périphériques avant le contrôle
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne (nettoyée si $trim_value), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_alphanumeric($params.code, true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_alphanumeric(
    $value: any,
    $trim_value: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = IF $trim_value { string::trim($value) } ELSE { $value };
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::is_alphanum($clean) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "alphanumeric" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne ne contient que des lettres et des chiffres. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
