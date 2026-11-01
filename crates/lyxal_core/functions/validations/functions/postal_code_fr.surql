-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/postal_code_fr.surql
-- Fonction : fn::validation_postal_code_fr
--
-- Valide un code postal français (5 chiffres, suivis de « CEDEX » et d'un
-- numéro facultatif si autorisé) ; la valeur renvoyée est en majuscules.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $allow_cedex : bool — true pour accepter la mention CEDEX
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le code postal en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $zip = fn::validation_postal_code_fr($params.postal_code, true);
--   IF !$zip.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $zip.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_postal_code_fr(
    $value: any,
    $allow_cedex: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, IF $allow_cedex { "^[0-9]{5}(?: CEDEX(?: [0-9]{1,2})?)?$" } ELSE { "^[0-9]{5}$" }) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "postal_code_fr" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code postal français (5 chiffres, suivis de « CEDEX » et d'un numéro facultatif si autorisé) ; la valeur renvoyée est en majuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
