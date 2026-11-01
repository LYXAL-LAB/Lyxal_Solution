-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/slug.surql
-- Fonction : fn::validation_slug
--
-- Valide un slug : chaîne nettoyée, mise en minuscules, composée de segments
-- [a-z0-9] séparés par un tiret simple.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $max_length : option<int> — longueur maximale (>= 1), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le slug en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $slug = fn::validation_slug($params.slug, 120);
--   IF !$slug.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $slug.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_slug(
    $value: any,
    $max_length: option<int>
) -> object {
    IF $max_length IS NOT NONE AND $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $slug = string::lowercase($clean);
    LET $length = string::len($slug);
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    IF !string::matches($slug, "^[a-z0-9]+(?:-[a-z0-9]+)*$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "slug" } }; };
    RETURN { valid: true, value: $slug, code: NONE, details: {} };
}
COMMENT "Valide un slug et le renvoie en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
