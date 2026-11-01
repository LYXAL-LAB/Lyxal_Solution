-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/forbidden_values.surql
-- Fonction : fn::validation_forbidden_values
--
-- Valide qu'une chaîne ne fait pas partie d'une liste de valeurs interdites
-- (égalité exacte).
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $forbidden_values : array<string> — valeurs interdites (au moins une, non vides)
--   $case_sensitive   : bool — false pour comparer sans tenir compte de la casse
--   $trim_value       : bool — true pour retirer les espaces périphériques avant le contrôle
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
--   CORE_INVALID_ARGUMENT : liste vide ou valeur vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_forbidden_values($params.slug, ["admin", "root"], false, true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_forbidden_values(
    $value: any,
    $forbidden_values: array<string>,
    $case_sensitive: bool,
    $trim_value: bool
) -> object {
    LET $items = array::map($forbidden_values, |$item| string::trim($item));
    IF array::len($items) = 0 OR array::any($items, |$item| $item = "") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = IF $trim_value { string::trim($value) } ELSE { $value };
    LET $subject = IF $case_sensitive { $clean } ELSE { string::lowercase($clean) };
    LET $hit = array::any($items, |$item| $subject = IF $case_sensitive { $item } ELSE { string::lowercase($item) });
    IF $hit { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne ne fait pas partie des valeurs interdites. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
