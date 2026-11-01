-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/ends_with.surql
-- Fonction : fn::validation_ends_with
--
-- Valide qu'une chaîne se termine par au moins un des suffixes donnés.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $suffixes       : array<string> — fragments recherchés (au moins un, non vides)
--   $case_sensitive : bool — false pour comparer sans tenir compte de la casse
--   $trim_value     : bool — true pour retirer les espaces périphériques avant le contrôle
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne (nettoyée si $trim_value), casse d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou fragment vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_ends_with($params.file_name, [".pdf"], false, true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ends_with(
    $value: any,
    $suffixes: array<string>,
    $case_sensitive: bool,
    $trim_value: bool
) -> object {
    LET $items = array::map($suffixes, |$item| string::trim($item));
    IF array::len($items) = 0 OR array::any($items, |$item| $item = "") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = IF $trim_value { string::trim($value) } ELSE { $value };
    LET $subject = IF $case_sensitive { $clean } ELSE { string::lowercase($clean) };
    LET $found = array::any($items, |$item| string::ends_with($subject, IF $case_sensitive { $item } ELSE { string::lowercase($item) }));
    IF !$found { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { ends_with_any: $items } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne se termine par au moins un des suffixes donnés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
