-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/company_name.surql
-- Fonction : fn::validation_company_name
--
-- Valide une raison sociale : lettres, chiffres, espaces et &+.,'()/_- ;
-- longueur bornée.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : int — longueur minimale (>= 1)
--   $max_length : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $company = fn::validation_company_name($params.company_name, 2, 200);
--   IF !$company.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $company.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_company_name(
    $value: any,
    $min_length: int,
    $max_length: int
) -> object {
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[\\p{L}\\p{M}\\p{N} &+.,'()/_\\-]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "company_name" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une raison sociale : lettres, chiffres, espaces et &+.,'()/_- ; longueur bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
