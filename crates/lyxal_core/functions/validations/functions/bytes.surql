-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/bytes.surql
-- Fonction : fn::validation_bytes
--
-- Valide qu'une valeur est de type bytes et, facultativement, que sa taille
-- en octets est comprise entre deux bornes incluses.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : option<int> — taille minimale en octets (>= 0), NONE pour aucune
--   $max_length : option<int> — taille maximale en octets (>= 0), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = les octets d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne négative ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_bytes($params.payload, 1, 1048576);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bytes(
    $value: any,
    $min_length: option<int>,
    $max_length: option<int>
) -> object {
    IF ($min_length IS NOT NONE AND $min_length < 0) OR ($max_length IS NOT NONE AND $max_length < 0) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $min_length IS NOT NONE AND $max_length IS NOT NONE AND $min_length > $max_length {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_bytes($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "bytes", actual: type::of($value) } };
    };
    LET $length = bytes::len($value);
    IF $min_length IS NOT NONE AND $length < $min_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } };
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur est de type bytes et que sa taille est comprise entre deux bornes facultatives. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
