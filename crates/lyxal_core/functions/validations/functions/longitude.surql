-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/longitude.surql
-- Fonction : fn::validation_longitude
--
-- Valide une longitude en degrés décimaux : nombre compris entre -180 et
-- 180.
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
--   LET $check = fn::validation_longitude($params.longitude);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_longitude(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_number($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: type::of($value) } };
    };
    IF $value < -180 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: -180 } }; };
    IF $value > 180 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 180 } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une longitude (-180 à 180). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
