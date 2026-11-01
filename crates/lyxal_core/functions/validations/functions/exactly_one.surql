-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/exactly_one.surql
-- Fonction : fn::validation_exactly_one
--
-- Valide qu'exactement une valeur d'un groupe de champs est présente
-- (différente de NONE).
--
-- Paramètres
--   $values : array<any> — valeurs des champs du groupe, assemblées par l'appelant (NONE = champ absent)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_COMBINATION
--
-- Exemple (dans une fonction de module)
--   LET $target = fn::validation_exactly_one([$params.user_id, $params.team_id]);
--   IF !$target.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $target.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_exactly_one(
    $values: array<any>
) -> object {
    LET $present = array::len(array::filter($values, |$item| $item IS NOT NONE));
    IF $present = 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } }; };
    IF $present > 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: $present, max: 1 } }; };
    RETURN { valid: true, value: $values, code: NONE, details: {} };
}
COMMENT "Valide qu'exactement une valeur du groupe est présente. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
