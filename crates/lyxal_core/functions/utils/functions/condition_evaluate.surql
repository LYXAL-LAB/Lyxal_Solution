-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/condition_evaluate.surql
-- Fonction : fn::utils_condition_evaluate
--
-- Évalue une condition sur une valeur (règle générique, sans métier) :
--   { all: [...] }  vraie si toutes les sous-conditions le sont (arrêt au premier échec)
--   { any: [...] }  vraie si l'une le est (arrêt au premier succès)
--   { not: {...} }  négation
--   { field, op, value }  règle sur le champ lu par fn::utils_object_get_path
-- Forme et limites : fn::utils_condition_check.
--
-- Opérateurs
--   eq, ne          égalité profonde (==) ; ne est vraie pour un champ absent
--   lt, lte, gt, gte, between (bornes incluses)
--                   nombres (fn::utils_compare_numbers), chaînes
--                   (fn::utils_compare_strings, sensible à la casse) ou dates
--                   (fn::utils_compare_dates), de même type
--   in, not_in      appartenance à la liste ; not_in est vraie pour un champ absent
--   contains        sous-chaîne d'une chaîne, ou élément d'un tableau
--   starts_with, ends_with  sur une chaîne
--   exists, missing champ présent (ni NONE ni NULL) ou absent
--   empty           absent, "", [] ou {}
--
-- Un champ absent ne lève jamais : la règle est fausse (sauf ne, not_in,
-- missing et empty). Des types incompatibles (comparer une chaîne à un nombre,
-- contains sur un nombre) rendent la règle fausse avec error = { field, op,
-- reason: "type_mismatch" } ; une négation d'une règle en erreur reste fausse.
--
-- Paramètres
--   $value     : any — valeur évaluée (un objet en général)
--   $condition : any — condition (forme contrôlée par fn::utils_condition_check)
--   $limits    : option<object> — { max_depth, max_rules } (voir fn::utils_condition_check)
--
-- Valeur renvoyée : object { matched, error }
--
-- Erreurs de programmation (THROW)
--   CORE_CONDITION_INVALID : condition de forme invalide (à contrôler à son
--                            enregistrement avec fn::utils_condition_check)
--   CORE_INVALID_ARGUMENT  : limites invalides
--
-- Exemple (dans une fonction de module)
--   LET $result = fn::utils_condition_evaluate({ payload: $params.payload }, $member.condition, NONE);
--   IF !$result.matched { ... };
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_condition_evaluate(
    $value: any,
    $condition: any,
    $limits: option<object>
) -> object {
    IF !fn::utils_condition_check($condition, $limits).valid {
        THROW "CORE_CONDITION_INVALID";
    };
    IF $condition.all IS NOT NONE {
        RETURN array::fold($condition.all, { matched: true, error: NONE }, |$acc, $child| {
            IF !$acc.matched { $acc } ELSE {
                LET $result = fn::utils_condition_evaluate($value, $child, $limits);
                { matched: $result.matched, error: $result.error }
            }
        });
    };
    IF $condition.any IS NOT NONE {
        RETURN array::fold($condition.any, { matched: false, error: NONE }, |$acc, $child| {
            IF $acc.matched { $acc } ELSE {
                LET $result = fn::utils_condition_evaluate($value, $child, $limits);
                IF $result.matched { { matched: true, error: NONE } } ELSE { { matched: false, error: $acc.error ?? $result.error } }
            }
        });
    };
    IF $condition.not IS NOT NONE {
        LET $result = fn::utils_condition_evaluate($value, $condition.not, $limits);
        RETURN IF $result.error IS NOT NONE { { matched: false, error: $result.error } } ELSE { { matched: !$result.matched, error: NONE } };
    };
    LET $op = $condition.op;
    LET $expected = $condition.value;
    LET $actual = IF type::is_object($value) {
        fn::utils_object_get_path($value, string::split($condition.field, "."), NONE)
    } ELSE { NONE };
    LET $present = $actual IS NOT NONE AND !type::is_null($actual);
    LET $mismatch = { matched: false, error: { field: $condition.field, op: $op, reason: "type_mismatch" } };
    IF $op = "exists" { RETURN { matched: $present, error: NONE }; };
    IF $op = "missing" { RETURN { matched: !$present, error: NONE }; };
    IF $op = "empty" { RETURN { matched: !$present OR $actual = "" OR $actual = [] OR $actual = {}, error: NONE }; };
    IF $op = "ne" { RETURN { matched: !$present OR $actual != $expected, error: NONE }; };
    IF $op = "not_in" { RETURN { matched: !$present OR $actual NOT IN $expected, error: NONE }; };
    IF !$present { RETURN { matched: false, error: NONE }; };
    IF $op = "eq" { RETURN { matched: $actual == $expected, error: NONE }; };
    IF $op = "in" { RETURN { matched: $actual IN $expected, error: NONE }; };
    -- Comparaison de deux valeurs de même type ordonné : -1, 0, 1, ou NONE si les types diffèrent
    LET $compare = |$a, $b| {
        IF type::is_number($a) AND type::is_number($b) { RETURN fn::utils_compare_numbers($a, $b, 0); };
        IF type::is_string($a) AND type::is_string($b) { RETURN fn::utils_compare_strings($a, $b, true, false); };
        IF type::is_datetime($a) AND type::is_datetime($b) { RETURN fn::utils_compare_dates($a, $b); };
        RETURN NONE;
    };
    IF $op IN ["lt", "lte", "gt", "gte"] {
        LET $order = $compare($actual, $expected);
        IF $order IS NONE { RETURN $mismatch; };
        RETURN { matched: IF $op = "lt" { $order < 0 } ELSE IF $op = "lte" { $order <= 0 } ELSE IF $op = "gt" { $order > 0 } ELSE { $order >= 0 }, error: NONE };
    };
    IF $op = "between" {
        LET $low = $compare($actual, $expected[0]);
        LET $high = $compare($actual, $expected[1]);
        IF $low IS NONE OR $high IS NONE { RETURN $mismatch; };
        RETURN { matched: $low >= 0 AND $high <= 0, error: NONE };
    };
    IF $op = "contains" {
        IF type::is_string($actual) AND type::is_string($expected) { RETURN { matched: string::contains($actual, $expected), error: NONE }; };
        IF type::is_array($actual) { RETURN { matched: $actual CONTAINS $expected, error: NONE }; };
        RETURN $mismatch;
    };
    -- starts_with, ends_with
    IF !type::is_string($actual) { RETURN $mismatch; };
    RETURN {
        matched: IF $op = "starts_with" { string::starts_with($actual, $expected) } ELSE { string::ends_with($actual, $expected) },
        error: NONE
    };
}
COMMENT "Évalue une condition (all, any, not, règles { field, op, value } : eq, ne, lt, lte, gt, gte, between, in, not_in, contains, starts_with, ends_with, exists, missing, empty) sur une valeur. Renvoie { matched, error } sans lever pour un champ absent ; forme invalide : CORE_CONDITION_INVALID."
PERMISSIONS FULL;
