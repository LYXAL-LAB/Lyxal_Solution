-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/initials.surql
-- Fonction : fn::validation_initials
--
-- Valide des initiales : lettres A-Z une fois retirés les espaces et les
-- points ; la valeur renvoyée est en majuscules, sans séparateur.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_count : int — nombre minimal de lettres (>= 1)
--   $max_count : int — nombre maximal de lettres (>= $min_count)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = les lettres en majuscules, sans séparateur, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_count < 1 ou $min_count > $max_count
--
-- Exemple (dans une fonction de module)
--   LET $initials = fn::validation_initials($params.initials, 1, 4);
--   IF !$initials.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $initials.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_initials(
    $value: any,
    $min_count: int,
    $max_count: int
) -> object {
    IF $min_count < 1 OR $min_count > $max_count { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $letters = string::uppercase(string::replace(string::replace($clean, " ", ""), ".", ""));
    LET $count = string::len($letters);
    IF !string::matches($letters, "^[A-Z]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "initials" } };
    };
    IF $count < $min_count {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_count: $min_count, count: $count } };
    };
    IF $count > $max_count {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_count: $max_count, count: $count } };
    };
    RETURN { valid: true, value: $letters, code: NONE, details: {} };
}
COMMENT "Valide des initiales : lettres A-Z une fois retirés les espaces et les points ; la valeur renvoyée est en majuscules, sans séparateur. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
