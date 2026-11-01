-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/hexadecimal.surql
-- Fonction : fn::validation_hexadecimal
--
-- Valide une chaîne hexadécimale, avec préfixe 0x facultatif si autorisé ;
-- les longueurs portent sur les chiffres, hors préfixe.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $min_length   : option<int> — nombre minimal de chiffres (>= 1), NONE pour aucun
--   $max_length   : option<int> — nombre maximal de chiffres (>= 1), NONE pour aucun
--   $allow_prefix : bool — true pour accepter le préfixe 0x / 0X
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne nettoyée, en minuscules (préfixe conservé), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_hexadecimal($params.color, 6, 6, false);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_hexadecimal(
    $value: any,
    $min_length: option<int>,
    $max_length: option<int>,
    $allow_prefix: bool
) -> object {
    IF ($min_length IS NOT NONE AND $min_length < 1) OR ($max_length IS NOT NONE AND $max_length < 1) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $min_length IS NOT NONE AND $max_length IS NOT NONE AND $min_length > $max_length {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $pattern = IF $allow_prefix { "^(0x|0X)?[0-9A-Fa-f]+$" } ELSE { "^[0-9A-Fa-f]+$" };
    IF !string::matches($clean, $pattern) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hexadecimal" } }; };
    LET $length = string::len($clean) - IF string::matches($clean, "^0[xX]") { 2 } ELSE { 0 };
    IF $min_length IS NOT NONE AND $length < $min_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } };
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    RETURN { valid: true, value: string::lowercase($clean), code: NONE, details: {} };
}
COMMENT "Valide une chaîne hexadécimale. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
