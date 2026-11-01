-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/percentage.surql
-- Fonction : fn::validation_percentage
--
-- Valide qu'une valeur numérique est un pourcentage compris entre deux
-- bornes incluses (ex. 0 et 100, ou 0 et 1).
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : number — borne minimale incluse
--   $max_value : number — borne maximale incluse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
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
--   LET $check = fn::validation_percentage($params.discount, 0, 100);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_percentage(
    $value: any,
    $min_value: number,
    $max_value: number
) -> object {
    IF $min_value > $max_value { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_number($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: type::of($value) } };
    };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un nombre est compris entre les bornes du pourcentage. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
