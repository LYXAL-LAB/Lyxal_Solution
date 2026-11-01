-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/required_string.surql
-- Fonction : fn::validation_required_string
--
-- Valide une chaîne obligatoire : présente, non vide après suppression des
-- espaces périphériques, de longueur comprise entre deux bornes
-- facultatives.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : option<int> — longueur minimale (>= 0), NONE pour aucune
--   $max_length : option<int> — longueur maximale (>= 0), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne négative ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $name = fn::validation_required_string($params.name, 1, 100);
--   IF !$name.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $name.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_required_string(
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
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $min_length IS NOT NONE AND $length < $min_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } };
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne obligatoire nettoyée de ses espaces et bornée en longueur. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
