-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/optional_string.surql
-- Fonction : fn::validation_optional_string
--
-- Valide une chaîne facultative : NONE ou une chaîne vide après nettoyage
-- donnent un résultat valide de valeur NONE ; sinon la longueur est
-- contrôlée.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : option<int> — longueur minimale (>= 0), NONE pour aucune
--   $max_length : option<int> — longueur maximale (>= 0), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, ou NONE si absente ou vide, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne négative ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $description = fn::validation_optional_string($params.description, NONE, 500);
--   IF !$description.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $description.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_optional_string(
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
    IF $value IS NONE { RETURN { valid: true, value: NONE, code: NONE, details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: true, value: NONE, code: NONE, details: {} }; };
    LET $length = string::len($clean);
    IF $min_length IS NOT NONE AND $length < $min_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } };
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne facultative (absente ou vide = NONE) bornée en longueur. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
