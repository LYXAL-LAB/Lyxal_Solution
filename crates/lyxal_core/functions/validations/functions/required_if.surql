-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/required_if.surql
-- Fonction : fn::validation_required_if
--
-- Valide la présence d'une valeur obligatoire lorsque la condition est vraie
-- ; sinon la valeur est acceptée telle quelle (y compris NONE).
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $condition  : bool — condition évaluée par l'appelant
--   $allow_null : bool — true pour accepter NULL quand la valeur est obligatoire
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_required_if($params.company_name, $params.is_company, false);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_required_if(
    $value: any,
    $condition: bool,
    $allow_null: bool
) -> object {
    IF !($condition) { RETURN { valid: true, value: $value, code: NONE, details: {} }; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF !$allow_null AND type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide la présence d'une valeur obligatoire lorsque la condition est vraie. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
