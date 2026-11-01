-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/geohash.surql
-- Fonction : fn::validation_geohash
--
-- Valide un geohash (alphabet base32 geohash, sans a, i, l ni o) ; la valeur
-- renvoyée est en minuscules.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : int — longueur minimale (>= 1)
--   $max_length : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le geohash en minuscules, code = NONE
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
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $cell = fn::validation_geohash($params.geohash, 5, 12);
--   IF !$cell.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $cell.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_geohash(
    $value: any,
    $min_length: int,
    $max_length: int
) -> object {
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
    IF !string::matches($clean, "^[0123456789bcdefghjkmnpqrstuvwxyz]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "geohash" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un geohash (alphabet base32 geohash, sans a, i, l ni o) ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
