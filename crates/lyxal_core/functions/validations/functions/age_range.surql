-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/age_range.surql
-- Fonction : fn::validation_age_range
--
-- Valide une date de naissance et l'âge révolu qu'elle donne aujourd'hui,
-- facultativement compris entre deux âges inclus.
--
-- Paramètres
--   $birthdate : any — date de naissance (datetime à minuit UTC)
--   $min_age   : option<int> — âge minimal inclus (>= 0), NONE pour aucun
--   $max_age   : option<int> — âge maximal inclus (>= 0), NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { birthdate, age }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : âge négatif ou $min_age > $max_age
--
-- Exemple (dans une fonction de module)
--   LET $adult = fn::validation_age_range($params.birthdate, 18, NONE);
--   IF !$adult.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $adult.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_age_range(
    $birthdate: any,
    $min_age: option<int>,
    $max_age: option<int>
) -> object {
    IF ($min_age IS NOT NONE AND $min_age < 0) OR ($max_age IS NOT NONE AND $max_age < 0) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $min_age IS NOT NONE AND $max_age IS NOT NONE AND $min_age > $max_age { THROW "CORE_INVALID_ARGUMENT"; };
    IF $birthdate IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($birthdate) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($birthdate) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($birthdate) } };
    };
    IF time::format($birthdate, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } }; };
    LET $today = time::floor(time::now(), 1d);
    IF $birthdate > $today { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $today } }; };
    LET $age = <int> time::format($today, "%Y") - <int> time::format($birthdate, "%Y")
        - IF time::format($today, "%m%d") < time::format($birthdate, "%m%d") { 1 } ELSE { 0 };
    IF $min_age IS NOT NONE AND $age < $min_age { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_age: $min_age, age: $age } }; };
    IF $max_age IS NOT NONE AND $age > $max_age { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_age: $max_age, age: $age } }; };
    RETURN { valid: true, value: { birthdate: $birthdate, age: $age }, code: NONE, details: {} };
}
COMMENT "Valide une date de naissance et l'âge révolu qui en découle. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
