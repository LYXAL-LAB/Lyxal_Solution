-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/duration.surql
-- Fonction : fn::validation_duration
--
-- Valide qu'une valeur est une durée SurrealDB et, facultativement, qu'elle
-- est comprise entre deux bornes incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<duration> — durée minimale incluse, NONE pour aucune
--   $max_value : option<duration> — durée maximale incluse, NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la durée d'origine, code = NONE
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
--   LET $timeout = fn::validation_duration($params.timeout, 1s, 5m);
--   IF !$timeout.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $timeout.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_duration(
    $value: any,
    $min_value: option<duration>,
    $max_value: option<duration>
) -> object {
    IF $min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_duration($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: type::of($value) } };
    };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une durée bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
