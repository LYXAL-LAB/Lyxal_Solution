-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/regex.surql
-- Fonction : fn::validation_regex
--
-- Valide qu'une chaîne non vide, nettoyée de ses espaces périphériques,
-- correspond à une expression régulière.
--
-- Paramètres
--   $value   : any — valeur à contrôler
--   $pattern : string — expression régulière (syntaxe Rust regex) ; un motif syntaxiquement invalide provoque l'erreur moteur de string::matches
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
--   CORE_INVALID_ARGUMENT : $pattern vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_regex($params.reference, "^REF-[0-9]{6}$");
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_regex(
    $value: any,
    $pattern: string
) -> object {
    IF string::trim($pattern) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, $pattern) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { pattern: $pattern } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne correspond à une expression régulière. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
