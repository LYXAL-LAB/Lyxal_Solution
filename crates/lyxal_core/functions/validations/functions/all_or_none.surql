-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/all_or_none.surql
-- Fonction : fn::validation_all_or_none
--
-- Valide que les valeurs d'un groupe de champs sont toutes présentes ou
-- toutes absentes (NONE).
--
-- Paramètres
--   $values : array<any> — valeurs des champs du groupe, assemblées par l'appelant (NONE = champ absent)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_COMBINATION
--
-- Exemple (dans une fonction de module)
--   LET $address = fn::validation_all_or_none([$params.street, $params.city, $params.postal_code]);
--   IF !$address.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $address.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_all_or_none(
    $values: array<any>
) -> object {
    LET $present = array::len(array::filter($values, |$item| $item IS NOT NONE));
    IF $present != 0 AND $present != array::len($values) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: $present, total: array::len($values) } };
    };
    RETURN { valid: true, value: $values, code: NONE, details: {} };
}
COMMENT "Valide que les valeurs du groupe sont toutes présentes ou toutes absentes. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
