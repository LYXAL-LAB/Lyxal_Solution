-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/at_least_one.surql
-- Fonction : fn::validation_at_least_one
--
-- Valide qu'au moins une valeur d'un groupe de champs est présente
-- (différente de NONE).
--
-- Paramètres
--   $values : array<any> — valeurs des champs du groupe, assemblées par l'appelant (NONE = champ absent)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--
-- Exemple (dans une fonction de module)
--   LET $contact = fn::validation_at_least_one([$params.email, $params.phone]);
--   IF !$contact.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $contact.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_at_least_one(
    $values: array<any>
) -> object {
    LET $present = array::len(array::filter($values, |$item| $item IS NOT NONE));
    IF $present = 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } }; };
    RETURN { valid: true, value: $values, code: NONE, details: {} };
}
COMMENT "Valide qu'au moins une valeur du groupe est présente. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
