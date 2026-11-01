-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/execution_priority.surql
-- Fonction : fn::validation_execution_priority
--
-- Valide une priorité d'exécution : entier compris entre deux bornes
-- incluses.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $min_priority : int — priorité minimale incluse
--   $max_priority : int — priorité maximale incluse (>= $min_priority)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'entier d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_priority > $max_priority
--
-- Exemple (dans une fonction de module)
--   LET $priority = fn::validation_execution_priority($params.priority, 0, 10);
--   IF !$priority.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $priority.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_execution_priority(
    $value: any,
    $min_priority: int,
    $max_priority: int
) -> object {
    IF $min_priority > $max_priority { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value < $min_priority { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_priority } }; };
    IF $value > $max_priority { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_priority } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une priorité d'exécution bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
