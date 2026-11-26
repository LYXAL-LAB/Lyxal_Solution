-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/fields_execute.surql
-- Fonction : fn::validation_fields_execute
--
-- Valide un objet champ par champ ; les contrôles de chaque champ sont des
-- fermetures remises par l'appelant, qui appellent les validateurs du Core
-- (|$v: any| fn::validation_record($v, "mail_account")). Forme du moteur
-- unique pour les fonctions appelées souvent : l'appelant ne nomme que les
-- validateurs qu'il utilise, alors que fn::validation_object_execute fait
-- charger tout le catalogue à chaque transaction. Champs exigés, valeurs par
-- défaut, NULL, clés inconnues et rapport sont ceux du moteur.
--
-- Paramètres
--   $value        : any
--   $fields       : object  { <champ>: { checks, required, nullable, default } }
--   $unknown_keys : string  reject, strip ou keep
--
-- Un contrôle reçoit la valeur du champ (celle du contrôle précédent) et rend :
--   * le résultat d'un validateur { valid, value, code, details } ;
--   * le rapport d'un objet imbriqué (cette fonction) : ses erreurs passent
--     sous le chemin du champ (reception.spf) ;
--   * un tableau de l'un ou de l'autre, un par élément d'un tableau : leurs
--     erreurs passent sous l'élément (items[0].content).
-- Les contrôles d'un champ s'arrêtent à la première erreur ; un champ en
-- erreur garde, dans le rapport, la valeur qu'il avait avant le contrôle.
--
-- Valeur renvoyée : object { valid, value, errors, warnings, by_field }, comme
-- fn::validation_object_execute (errors : { path, rule, code, details } ;
-- rule : required, nullable, unknown_keys, is_object, ou checks[<rang>]).
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT    : $fields vide, définition de champ ou résultat de contrôle invalide
--   CORE_UNSUPPORTED_OPTION  : $unknown_keys inconnu
-- Un contrôle qui n'est pas une fermeture est refusé par la base à son appel.
--
-- Coût : lire une valeur la recopie, fermetures comprises. Les contrôles d'un
-- champ sont donc mis à part une fois, et le cas courant (résultat satisfait)
-- sort au plus tôt des fermetures appelées pour chaque champ et chaque contrôle.
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_fields_execute(
    $value: any,
    $fields: object,
    $unknown_keys: string
) -> object {
    IF object::is_empty($fields) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $unknown_keys NOT IN ["reject", "strip", "keep"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF !type::is_object($value) {
        LET $checked = fn::validation_object($value);
        RETURN {
            valid: false, value: $value,
            errors: [{ path: "", rule: "is_object", code: $checked.code, details: $checked.details }],
            warnings: [], by_field: { "$": [$checked.code] }
        };
    };
    LET $keys = object::keys($fields);
    LET $states = array::map(object::values($fields), |$field, $position| {
        -- Lire une valeur la recopie, fermetures comprises : les contrôles sont mis à part une fois,
        -- le reste de la définition (required, nullable, default) se lit ensuite sans eux
        LET $checks = $field.checks ?? [];
        LET $definition = IF type::is_object($field) { object::remove($field, "checks") } ELSE { THROW "CORE_INVALID_ARGUMENT" };
        IF !type::is_array($checks)
            OR !array::is_empty(array::complement(object::keys($definition), ["required", "nullable", "default"]))
            OR !array::is_empty(array::complement([$definition.required, $definition.nullable], [NONE, true, false]))
        { THROW "CORE_INVALID_ARGUMENT"; };
        LET $key = $keys[$position];
        LET $given = $value[$key];
        LET $raw = IF $given IS NONE { $definition.default } ELSE { $given };
        IF $raw IS NONE {
            RETURN { value: NONE, errors: IF $definition.required == true { [{ path: $key, rule: "required", code: "CORE_VALIDATION_REQUIRED", details: {} }] } ELSE { [] }, warnings: [] };
        };
        IF type::is_null($raw) {
            RETURN { value: NULL, errors: IF $definition.nullable == true { [] } ELSE { [{ path: $key, rule: "nullable", code: "CORE_VALIDATION_NULL", details: {} }] }, warnings: [] };
        };
        RETURN array::fold($checks, { value: $raw, errors: [], warnings: [] }, |$state, $check, $rank| {
            IF !array::is_empty($state.errors) { RETURN $state; };
            LET $outcome = $check($state.value);
            LET $many = type::is_array($outcome);
            -- Cas courant : résultats satisfaits et sans avertissement, leur valeur normalisée remplace celle du champ
            IF (IF $many { array::all($outcome.valid, true) AND array::is_empty(array::flatten($outcome.warnings)[WHERE $this IS NOT NONE]) }
                ELSE { $outcome.valid == true AND array::is_empty($outcome.warnings ?? []) })
            { RETURN { value: $outcome.value, errors: [], warnings: $state.warnings }; };
            -- Sinon, résultats ramenés à { value, errors, warnings } : un par élément d'un tableau, sinon un seul
            LET $lifted = array::map(IF $many { $outcome } ELSE { [$outcome] }, |$item, $index| {
                IF !type::is_object($item) OR !type::is_bool($item.valid) { THROW "CORE_INVALID_ARGUMENT"; };
                LET $path = IF $many { $key + "[" + <string> $index + "]" } ELSE { $key };
                IF type::is_array($item.errors) {
                    LET $under = |$issue: object| object::extend($issue, { path: IF $issue.path == "" { $path } ELSE { $path + "." + $issue.path } });
                    RETURN { value: $item.value, errors: array::map($item.errors, $under), warnings: array::map($item.warnings ?? [], $under) };
                };
                IF $item.valid { RETURN { value: $item.value, errors: [], warnings: [] }; };
                IF !type::is_string($item.code) { THROW "CORE_INVALID_ARGUMENT"; };
                RETURN {
                    value: IF $many { $state.value[$index] } ELSE { $state.value },
                    errors: [{ path: $path, rule: "checks[" + <string> $rank + "]", code: $item.code, details: $item.details ?? {} }],
                    warnings: []
                };
            });
            RETURN {
                value: IF $many { $lifted.value } ELSE { $lifted[0].value },
                errors: array::flatten($lifted.errors),
                warnings: array::concat($state.warnings, array::flatten($lifted.warnings))
            };
        });
    });
    LET $unknown = IF $unknown_keys == "reject" {
        array::map(array::complement(object::keys($value), $keys), |$key| { path: $key, rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: $key } })
    } ELSE { [] };
    LET $errors = array::concat(array::flatten($states.errors), $unknown);
    LET $known = object::from_entries(array::transpose([$keys, $states.value])[WHERE $this[1] IS NOT NONE]);
    RETURN {
        valid: array::is_empty($errors),
        value: IF $unknown_keys == "keep" { object::extend(object::remove($value, $keys), $known) } ELSE { $known },
        errors: $errors,
        warnings: array::flatten($states.warnings),
        by_field: IF array::is_empty($errors) { {} } ELSE { fn::utils_engine_by_field($errors) }
    };
}
COMMENT "Valide un objet champ par champ ({ <champ>: { checks, required, nullable, default } }, clés inconnues : reject, strip ou keep) ; les contrôles sont des fermetures de l'appelant qui appellent les validateurs du Core, et rendent le résultat d'un validateur, le rapport d'un objet imbriqué, ou un tableau de l'un ou de l'autre (éléments d'un tableau). Renvoie le rapport { valid, value, errors, warnings, by_field } de fn::validation_object_execute ; une valeur qui n'est pas un objet donne l'erreur de fn::validation_object."
PERMISSIONS FULL;
