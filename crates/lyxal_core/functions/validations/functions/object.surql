-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/object.surql
-- Fonction : fn::validation_object
--
-- Valide qu'une valeur est un objet.
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
--
-- Exemple (dans une fonction de module)
--   LET $settings = fn::validation_object($params.settings);
--   IF !$settings.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $settings.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur est un objet. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
