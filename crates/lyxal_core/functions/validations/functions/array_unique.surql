-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_unique.surql
-- Fonction : fn::validation_array_unique
--
-- Valide qu'un tableau ne contient aucun doublon (égalité SurrealQL : 1 et
-- 1.0 sont des doublons).
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_DUPLICATE
--
-- Exemple (dans une fonction de module)
--   LET $ids = fn::validation_array_unique($params.ids);
--   IF !$ids.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $ids.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_unique(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF array::len($value) != array::len(array::distinct($value)) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_DUPLICATE", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau sans doublon. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
