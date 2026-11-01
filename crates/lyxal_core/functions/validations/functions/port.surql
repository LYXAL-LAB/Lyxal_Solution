-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/port.surql
-- Fonction : fn::validation_port
--
-- Valide un numéro de port TCP/UDP : entier compris entre deux bornes
-- incluses (0 à 65535).
--
-- Paramètres
--   $value    : any — valeur à contrôler
--   $min_port : int — port minimal inclus (>= 0)
--   $max_port : int — port maximal inclus (<= 65535)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'entier d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_port < 0, $max_port > 65535 ou $min_port > $max_port
--
-- Exemple (dans une fonction de module)
--   LET $port = fn::validation_port($params.port, 1024, 65535);
--   IF !$port.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $port.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_port(
    $value: any,
    $min_port: int,
    $max_port: int
) -> object {
    IF $min_port < 0 OR $max_port > 65535 OR $min_port > $max_port { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value < $min_port { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_port } }; };
    IF $value > $max_port { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_port } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un numéro de port borné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
