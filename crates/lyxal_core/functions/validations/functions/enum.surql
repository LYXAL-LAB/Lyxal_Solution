-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/enum.surql
-- Fonction : fn::validation_enum
--
-- Valide qu'une chaîne, nettoyée de ses espaces périphériques, fait partie
-- d'une liste de valeurs autorisées.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allowed        : array<string> — valeurs autorisées (au moins une, non vides)
--   $case_sensitive : bool — false pour comparer sans tenir compte de la casse (la valeur renvoyée est alors en minuscules)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne nettoyée (en minuscules si $case_sensitive = false), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou valeur vide
--
-- Exemple (dans une fonction de module)
--   LET $role = fn::validation_enum($params.role, ["owner", "admin", "member"], false);
--   IF !$role.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $role.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_enum(
    $value: any,
    $allowed: array<string>,
    $case_sensitive: bool
) -> object {
    LET $choices = array::map($allowed, |$item| IF $case_sensitive { string::trim($item) } ELSE { string::lowercase(string::trim($item)) });
    IF array::len($choices) = 0 OR array::any($choices, |$item| $item = "") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $candidate = IF $case_sensitive { $clean } ELSE { string::lowercase($clean) };
    IF $candidate NOT IN $choices { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $choices } }; };
    RETURN { valid: true, value: $candidate, code: NONE, details: {} };
}
COMMENT "Valide qu'une chaîne fait partie des valeurs autorisées. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
