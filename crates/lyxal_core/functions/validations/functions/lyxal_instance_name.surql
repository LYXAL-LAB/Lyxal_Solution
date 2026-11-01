-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/lyxal_instance_name.surql
-- Fonction : fn::validation_lyxal_instance_name
--
-- Valide un nom d'instance Lyxal : [a-z][a-z0-9-]*, sans « -- » ni tiret
-- final ; suffixe « -<environnement> » exigé si un environnement est donné.
-- La valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $environment : option<string> — environnement attendu parmi ["dev", "test", "staging", "prod"], NONE pour aucun
--   $min_length  : int — longueur minimale (>= 1)
--   $max_length  : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nom en minuscules, code = NONE
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
--   CORE_UNSUPPORTED_OPTION : environnement inconnu
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $instance = fn::validation_lyxal_instance_name($params.instance, "prod", 3, 63);
--   IF !$instance.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $instance.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_instance_name(
    $value: any,
    $environment: option<string>,
    $min_length: int,
    $max_length: int
) -> object {
    LET $env = IF $environment IS NONE { NONE } ELSE { string::lowercase(string::trim($environment)) };
    IF $env IS NOT NONE AND $env NOT IN ["dev", "test", "staging", "prod"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_instance_name" } };
    };
    IF $env IS NOT NONE AND !string::ends_with($clean, "-" + $env) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_instance_name", environment: $env } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom d'instance Lyxal : [a-z][a-z0-9-]*, sans « -- » ni tiret final ; suffixe « -<environnement> » exigé si un environnement est donné. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
