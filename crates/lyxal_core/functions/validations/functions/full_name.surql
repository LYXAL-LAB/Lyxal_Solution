-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/full_name.surql
-- Fonction : fn::validation_full_name
--
-- Valide un nom complet : mots de lettres séparés par une espace, une
-- apostrophe ou un tiret ; nombre de mots (séparés par une espace) et
-- longueur bornés.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_words  : int — nombre minimal de mots (>= 1)
--   $max_words  : int — nombre maximal de mots (>= $min_words)
--   $max_length : int — longueur maximale (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_words < 1, $min_words > $max_words ou $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $name = fn::validation_full_name($params.full_name, 2, 5, 200);
--   IF !$name.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $name.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_full_name(
    $value: any,
    $min_words: int,
    $max_words: int,
    $max_length: int
) -> object {
    IF $min_words < 1 OR $min_words > $max_words OR $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $words = array::len(string::split($clean, " "));
    LET $length = string::len($clean);
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[\\p{L}\\p{M}]+(?:[ '\\-][\\p{L}\\p{M}]+)*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "full_name" } };
    };
    IF $words < $min_words {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_words: $min_words, words: $words } };
    };
    IF $words > $max_words {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_words: $max_words, words: $words } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom complet : mots de lettres séparés par une espace, une apostrophe ou un tiret ; nombre de mots (séparés par une espace) et longueur bornés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
