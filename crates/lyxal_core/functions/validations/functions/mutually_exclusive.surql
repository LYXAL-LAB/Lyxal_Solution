-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/mutually_exclusive.surql
-- Fonction : fn::validation_mutually_exclusive
--
-- Valide qu'au plus une valeur d'un groupe de champs est présente ;
-- l'absence de toute valeur est acceptée seulement si autorisé.
--
-- Paramètres
--   $values             : array<any> — valeurs des champs du groupe, assemblées par l'appelant (NONE = champ absent)
--   $allow_none_present : bool — true pour accepter qu'aucune valeur ne soit présente
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_COMBINATION
--
-- Exemple (dans une fonction de module)
--   LET $mode = fn::validation_mutually_exclusive([$params.coupon, $params.voucher], true);
--   IF !$mode.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $mode.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_mutually_exclusive(
    $values: array<any>,
    $allow_none_present: bool
) -> object {
    LET $present = array::len(array::filter($values, |$item| $item IS NOT NONE));
    IF $present > 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: $present, max: 1 } }; };
    IF !$allow_none_present AND $present = 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } }; };
    RETURN { valid: true, value: $values, code: NONE, details: {} };
}
COMMENT "Valide qu'au plus une valeur du groupe est présente. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
