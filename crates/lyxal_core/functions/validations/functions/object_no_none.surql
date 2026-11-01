-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/object_no_none.surql
-- Fonction : fn::validation_object_no_none
--
-- Valide qu'aucune clé d'un objet n'a la valeur NONE.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l’objet d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_REQUIRED
--
-- Exemple (dans une fonction de module)
--   LET $patch = fn::validation_object_no_none($params.patch);
--   IF !$patch.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $patch.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_no_none(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    LET $keys = array::filter(object::keys($value), |$key| $value[$key] IS NONE);
    IF array::len($keys) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "value", keys: $keys } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un objet sans valeur NONE. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
