-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/condition_check.surql
-- Fonction : fn::utils_condition_check
--
-- Contrôle la forme d'une condition sans l'évaluer : groupes { all: [...] },
-- { any: [...] }, { not: {...} } et règles { field, op, value }. Ne lève pas
-- pour une condition invalide : le module qui enregistre une condition lit
-- `valid` et renvoie sa propre erreur.
--
-- Forme d'une règle
--   field : chemin dans la valeur évaluée, segments séparés par des points
--           ([A-Za-z0-9_-], 256 caractères au plus), ex. "payload.montant"
--   op    : eq, ne, lt, lte, gt, gte, between, in, not_in, contains,
--           starts_with, ends_with, exists, missing, empty
--   value : absente pour exists, missing, empty ; tableau de deux bornes de
--           même type (nombre, chaîne ou date) pour between ; tableau de 1 à
--           100 valeurs pour in et not_in ; nombre, chaîne ou date pour lt,
--           lte, gt, gte ; chaîne pour starts_with et ends_with ; présente
--           pour eq, ne et contains
--
-- Paramètres
--   $condition : any — condition à contrôler
--   $limits    : option<object> — { max_depth, max_rules } : profondeur de 1 à
--                10 (5 par défaut), règles de 1 à 200 (50 par défaut)
--
-- Valeur renvoyée : object
--   { valid, code, details, rules, depth }
--   valid = false → code = "CORE_CONDITION_INVALID", details = { path, reason },
--   reason parmi : not_object, empty_group, unknown_keys, invalid_field,
--   unknown_operator, missing_value, unexpected_value, invalid_value,
--   too_many_rules, too_deep ; path désigne le nœud fautif ("$.all[1].not")
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : limite inconnue, non entière ou hors plafond
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::utils_condition_check($params.condition, NONE);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_CONDITION_INVALID", $params.language, $check.details);
--   };
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_condition_check(
    $condition: any,
    $limits: option<object>
) -> object {
    LET $l = $limits ?? {};
    IF array::len(array::complement(object::keys($l), ["max_depth", "max_rules"])) > 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };
    LET $max_depth = $l.max_depth ?? 5;
    LET $max_rules = $l.max_rules ?? 50;
    IF !type::is_int($max_depth) OR $max_depth < 1 OR $max_depth > 10
        OR !type::is_int($max_rules) OR $max_rules < 1 OR $max_rules > 200 {
        THROW "CORE_INVALID_ARGUMENT";
    };
    LET $ordered = |$v| type::is_number($v) OR type::is_string($v) OR type::is_datetime($v);
    LET $same_kind = |$a, $b| (type::is_number($a) AND type::is_number($b))
        OR (type::is_string($a) AND type::is_string($b))
        OR (type::is_datetime($a) AND type::is_datetime($b));
    -- Contrôle d'un nœud : { issue, children, rule }
    LET $inspect = |$node, $path| {
        IF !type::is_object($node) { RETURN { issue: "not_object", children: [], rule: false }; };
        LET $keys = object::keys($node);
        IF $keys = ["all"] OR $keys = ["any"] {
            LET $group = $keys[0];
            LET $items = $node[$group];
            IF !type::is_array($items) { RETURN { issue: "invalid_value", children: [], rule: false }; };
            IF array::len($items) = 0 { RETURN { issue: "empty_group", children: [], rule: false }; };
            RETURN {
                issue: NONE,
                children: array::map($items, |$child, $index| {
                    node: $child,
                    path: string::concat($path, ".", $group, "[", <string> $index, "]")
                }),
                rule: false
            };
        };
        IF $keys = ["not"] {
            RETURN { issue: NONE, children: [{ node: $node.not, path: string::concat($path, ".not") }], rule: false };
        };
        IF array::len(array::complement($keys, ["field", "op", "value"])) > 0 {
            RETURN { issue: "unknown_keys", children: [], rule: false };
        };
        IF !type::is_string($node.field) OR string::len($node.field) < 1 OR string::len($node.field) > 256
            OR !string::matches($node.field, "^[A-Za-z0-9_-]+(\\.[A-Za-z0-9_-]+)*$") {
            RETURN { issue: "invalid_field", children: [], rule: false };
        };
        LET $op = $node.op;
        IF $op NOT IN ["eq", "ne", "lt", "lte", "gt", "gte", "between", "in", "not_in", "contains", "starts_with", "ends_with", "exists", "missing", "empty"] {
            RETURN { issue: "unknown_operator", children: [], rule: false };
        };
        LET $value = $node.value;
        IF $op IN ["exists", "missing", "empty"] {
            RETURN { issue: IF $value IS NONE { NONE } ELSE { "unexpected_value" }, children: [], rule: true };
        };
        IF $value IS NONE { RETURN { issue: "missing_value", children: [], rule: true }; };
        LET $valid = IF $op = "between" {
            type::is_array($value) AND array::len($value) = 2 AND $ordered($value[0]) AND $same_kind($value[0], $value[1])
        } ELSE IF $op IN ["in", "not_in"] {
            type::is_array($value) AND array::len($value) >= 1 AND array::len($value) <= 100
        } ELSE IF $op IN ["lt", "lte", "gt", "gte"] {
            $ordered($value)
        } ELSE IF $op IN ["starts_with", "ends_with"] {
            type::is_string($value)
        } ELSE { true };
        RETURN { issue: IF $valid { NONE } ELSE { "invalid_value" }, children: [], rule: true };
    };
    -- Parcours en largeur, un niveau de profondeur par tour
    LET $final = array::fold(<array>(0..$max_depth), { pending: [{ node: $condition, path: "$" }], rules: 0, depth: 0, error: NONE }, |$state, $level| {
        IF $state.error IS NOT NONE OR array::len($state.pending) = 0 { $state } ELSE {
            array::fold($state.pending, { pending: [], rules: $state.rules, depth: $level + 1, error: NONE }, |$acc, $item| {
                IF $acc.error IS NOT NONE { $acc } ELSE {
                    LET $seen = $inspect($item.node, $item.path);
                    LET $rules = $acc.rules + IF $seen.rule { 1 } ELSE { 0 };
                    IF $seen.issue IS NOT NONE {
                        { pending: [], rules: $rules, depth: $acc.depth, error: { path: $item.path, reason: $seen.issue } }
                    } ELSE IF $rules > $max_rules {
                        { pending: [], rules: $rules, depth: $acc.depth, error: { path: $item.path, reason: "too_many_rules" } }
                    } ELSE {
                        { pending: array::concat($acc.pending, $seen.children), rules: $rules, depth: $acc.depth, error: NONE }
                    }
                }
            })
        }
    });
    LET $error = IF $final.error IS NONE AND array::len($final.pending) > 0 {
        { path: $final.pending[0].path, reason: "too_deep" }
    } ELSE { $final.error };
    RETURN IF $error IS NONE {
        { valid: true, code: NONE, details: {}, rules: $final.rules, depth: $final.depth }
    } ELSE {
        { valid: false, code: "CORE_CONDITION_INVALID", details: $error, rules: $final.rules, depth: $final.depth }
    };
}
COMMENT "Contrôle la forme d'une condition (all, any, not, règles { field, op, value }) sous des limites de profondeur et de nombre de règles. Renvoie { valid, code, details, rules, depth } sans lever pour une condition invalide."
PERMISSIONS FULL;
