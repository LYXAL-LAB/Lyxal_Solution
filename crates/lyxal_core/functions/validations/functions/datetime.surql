-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/datetime.surql
-- Fonction : fn::validation_datetime
--
-- Valide qu'une valeur est un datetime SurrealDB et, facultativement, qu'il
-- est compris entre deux bornes incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<datetime> — borne minimale incluse, NONE pour aucune
--   $max_value : option<datetime> — borne maximale incluse, NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le datetime d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_value > $max_value
--
-- Exemple (dans une fonction de module)
--   LET $start = fn::validation_datetime($params.start_at, NONE, NONE);
--   IF !$start.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $start.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_datetime(
    $value: any,
    $min_value: option<datetime>,
    $max_value: option<datetime>
) -> object {
    IF $min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un datetime borné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
