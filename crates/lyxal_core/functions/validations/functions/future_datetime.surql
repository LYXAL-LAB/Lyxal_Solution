-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/future_datetime.surql
-- Fonction : fn::validation_future_datetime
--
-- Valide qu'un datetime est dans le futur par rapport à une référence (par
-- défaut maintenant), avec un délai d'avance minimal et maximal facultatif.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $reference_value : option<datetime> — instant de référence, NONE pour time::now()
--   $allow_equal     : bool — true pour accepter un instant égal à la référence
--   $min_advance     : option<duration> — écart minimal avec la référence, NONE pour aucun
--   $max_advance     : option<duration> — écart maximal avec la référence, NONE pour aucun
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
--   CORE_INVALID_ARGUMENT : $min_advance > $max_advance, ou $max_advance = 0ns sans $allow_equal
--
-- Exemple (dans une fonction de module)
--   LET $at = fn::validation_future_datetime($params.at, NONE, false, NONE, NONE);
--   IF !$at.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $at.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_future_datetime(
    $value: any,
    $reference_value: option<datetime>,
    $allow_equal: bool,
    $min_advance: option<duration>,
    $max_advance: option<duration>
) -> object {
    IF $min_advance IS NOT NONE AND $max_advance IS NOT NONE AND $min_advance > $max_advance { THROW "CORE_INVALID_ARGUMENT"; };
    IF !$allow_equal AND $max_advance IS NOT NONE AND $max_advance = 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    LET $reference = $reference_value ?? time::now();
    IF ($allow_equal AND $value < $reference) OR (!$allow_equal AND $value <= $reference) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $reference, exclusive: !$allow_equal } };
    };
    LET $advance = $value - $reference;
    IF $min_advance IS NOT NONE AND $advance < $min_advance { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_advance: $min_advance, advance: $advance } }; };
    IF $max_advance IS NOT NONE AND $advance > $max_advance { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_advance: $max_advance, advance: $advance } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un datetime est dans le futur par rapport à une référence (par défaut maintenant), avec un délai d'avance minimal et maximal facultatif. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
