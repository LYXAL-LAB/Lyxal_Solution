-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/latitude.surql
-- Fonction : fn::validation_latitude
--
-- Valide une latitude en degrés décimaux : nombre compris entre -90 et 90.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nombre d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_latitude($params.latitude);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_latitude(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_number($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: type::of($value) } };
    };
    IF $value < -90 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: -90 } }; };
    IF $value > 90 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 90 } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une latitude (-90 à 90). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
