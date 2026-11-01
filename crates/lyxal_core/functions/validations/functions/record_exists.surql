-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/record_exists.surql
-- Fonction : fn::validation_record_exists
--
-- Valide qu'une valeur est un Record ID natif dont l'enregistrement existe
-- en base.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le Record ID d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_FOUND
--
-- Exemple (dans une fonction de module)
--   LET $team = fn::validation_record_exists($params.team);
--   IF !$team.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $team.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record_exists(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_record($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "record", actual: type::of($value) } };
    };
    IF !record::exists($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un enregistrement existe. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
