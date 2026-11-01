-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/reserved_words.surql
-- Fonction : fn::validation_reserved_words
--
-- Valide qu'une chaîne n'est pas un mot réservé (comparaison toujours
-- insensible à la casse).
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $reserved_words : array<string> — mots réservés (au moins un, non vides)
--   $trim_value     : bool — true pour retirer les espaces périphériques avant le contrôle
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne (nettoyée si $trim_value), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORBIDDEN
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou mot vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_reserved_words($params.username, ["admin", "system"], true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_reserved_words(
    $value: any,
    $reserved_words: array<string>,
    $trim_value: bool
) -> object {
    LET $words = array::map($reserved_words, |$word| string::lowercase(string::trim($word)));
    IF array::len($words) = 0 OR array::any($words, |$word| $word = "") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = IF $trim_value { string::trim($value) } ELSE { $value };
    IF string::lowercase($clean) IN $words { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne n'est pas un mot réservé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
