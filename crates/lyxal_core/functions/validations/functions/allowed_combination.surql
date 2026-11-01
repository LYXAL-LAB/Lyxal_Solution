-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/allowed_combination.surql
-- Fonction : fn::validation_allowed_combination
--
-- Valide qu'un groupe de valeurs correspond exactement à l'une des
-- combinaisons autorisées.
--
-- Paramètres
--   $values               : array<any> — valeurs du groupe, assemblées par l'appelant
--   $allowed_combinations : array<array<any>> — combinaisons autorisées (au moins une, de même longueur que $values)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_COMBINATION
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou combinaison de longueur différente
--
-- Exemple (dans une fonction de module)
--   LET $pair = fn::validation_allowed_combination([$params.kind, $params.unit], [["weight", "kg"], ["length", "m"]]);
--   IF !$pair.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $pair.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_allowed_combination(
    $values: array<any>,
    $allowed_combinations: array<array<any>>
) -> object {
    IF array::len($allowed_combinations) = 0
        OR array::any($allowed_combinations, |$combination| array::len($combination) != array::len($values)) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $values NOT IN $allowed_combinations { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { allowed: $allowed_combinations } }; };
    RETURN { valid: true, value: $values, code: NONE, details: {} };
}
COMMENT "Valide qu'un groupe de valeurs est une combinaison autorisée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
