-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/enum_any.surql
-- Fonction : fn::validation_enum_any
--
-- Valide qu'une valeur de n'importe quel type fait partie d'une liste de
-- valeurs autorisées (égalité SurrealQL, sans conversion).
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allowed_values : array<any> — valeurs autorisées (au moins une)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_enum_any($params.priority, [1, 2, 3]);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_enum_any(
    $value: any,
    $allowed_values: array<any>
) -> object {
    IF array::len($allowed_values) = 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF $value NOT IN $allowed_values { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed_values } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur fait partie des valeurs autorisées. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
