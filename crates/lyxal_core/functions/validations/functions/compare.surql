-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/compare.surql
-- Fonction : fn::validation_compare
--
-- Valide que deux valeurs respectent un opérateur de comparaison (eq, neq,
-- gt, gte, lt, lte).
--
-- Paramètres
--   $left     : any — valeur de gauche
--   $right    : any — valeur de droite
--   $operator : string — "eq", "neq", "gt", "gte", "lt" ou "lte", insensible à la casse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { left, right, operator }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_COMPARISON
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : opérateur inconnu
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_compare($params.end_at, $params.start_at, "gt");
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compare(
    $left: any,
    $right: any,
    $operator: string
) -> object {
    LET $op = string::lowercase(string::trim($operator));
    IF $op NOT IN ["eq", "neq", "gt", "gte", "lt", "lte"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $left IS NONE OR $right IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    LET $holds = IF $op = "eq" { $left == $right }
        ELSE IF $op = "neq" { $left != $right }
        ELSE IF $op = "gt" { $left > $right }
        ELSE IF $op = "gte" { $left >= $right }
        ELSE IF $op = "lt" { $left < $right }
        ELSE { $left <= $right };
    IF !$holds { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_COMPARISON", details: { operator: $op } }; };
    RETURN { valid: true, value: { left: $left, right: $right, operator: $op }, code: NONE, details: {} };
}
COMMENT "Valide que deux valeurs respectent l'opérateur de comparaison. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
