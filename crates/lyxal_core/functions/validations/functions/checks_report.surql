-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/checks_report.surql
-- Fonction : fn::validation_checks_report
--
-- Rapport d'un objet dont les champs ont déjà été contrôlés : l'appelant a
-- appelé lui-même les validateurs du Core, un par champ, et remet leurs
-- résultats. Pour les fonctions du worker appelées par lots (éléments d'une
-- remise de courrier) : sans fermeture par champ, le coût ne monte ni avec la
-- taille du lot ni avec celle des valeurs (fn::validation_fields_execute
-- recopie ses variables à chaque contrôle). Ailleurs, l'exécuteur
-- fn::validation_fields_execute reste la forme à employer : ici, champs
-- exigés, valeurs par défaut et enchaînement des contrôles sont écrits par
-- l'appelant.
--
-- Paramètres
--   $value  : any     objet contrôlé
--   $checks : object  { <champ>: résultat du contrôle de ce champ }
--
-- Le résultat d'un champ a l'une des formes que rend un contrôle de
-- fn::validation_fields_execute :
--   * le résultat d'un validateur { valid, value, code, details } ;
--   * le rapport d'un objet imbriqué (cette fonction ou
--     fn::validation_fields_execute) : ses erreurs passent sous le chemin du
--     champ (reception.spf) ;
--   * un tableau de l'un ou de l'autre, un par élément d'un tableau : leurs
--     erreurs passent sous l'élément (items[0].content).
-- Un validateur appelé sur une valeur absente rend CORE_VALIDATION_REQUIRED
-- (champ exigé) et sur NULL CORE_VALIDATION_NULL, comme l'exécuteur ; un champ
-- facultatif absent se contrôle par un validateur qui accepte NONE
-- (fn::validation_optional_string) ou sur sa valeur par défaut
-- (IF $v IS NONE { <défaut> } ELSE { $v } : « ?? » remplacerait aussi NULL).
-- Toute clé de $value absente de $checks est refusée
-- (CORE_VALIDATION_NOT_ALLOWED).
--
-- Valeur renvoyée : object { valid, value, errors, warnings, by_field }, le
-- rapport de fn::validation_fields_execute en mode « reject » : mêmes codes,
-- mêmes chemins, même by_field ; il se remet tel quel comme résultat d'un
-- champ à l'une ou l'autre fonction. value : valeurs normalisées des champs
-- contrôlés (un champ dont la valeur est NONE est omis ; un champ en erreur
-- garde la valeur reçue). errors : { path, rule, code, details } ; rule :
-- check, unknown_keys ou is_object. Une valeur qui n'est pas un objet donne
-- l'erreur de fn::validation_object, à la racine.
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $checks vide, ou résultat d'un champ qui n'est ni
--                           un résultat de validateur ni un rapport
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_checks_report(
    $value: any,
    $checks: object
) -> object {
    IF object::is_empty($checks) { THROW "CORE_INVALID_ARGUMENT"; };
    IF !type::is_object($value) {
        LET $checked = fn::validation_object($value);
        RETURN {
            valid: false, value: $value,
            errors: [{ path: "", rule: "is_object", code: $checked.code, details: $checked.details }],
            warnings: [], by_field: { "$": [$checked.code] }
        };
    };
    LET $keys = object::keys($checks);
    LET $outcomes = object::values($checks);
    LET $unknown = array::complement(object::keys($value), $keys);
    -- Cas courant, sans aucune fermeture : tout est satisfait, sans avertissement ni clé inconnue
    LET $flat = array::flatten($outcomes);
    IF array::is_empty($unknown) AND array::all($flat.valid, true) AND array::is_empty(array::flatten($flat.warnings)[WHERE $this IS NOT NONE]) {
        RETURN {
            valid: true,
            value: object::from_entries(array::transpose([$keys, $outcomes.value])[WHERE $this[1] IS NOT NONE]),
            errors: [], warnings: [], by_field: {}
        };
    };
    -- Sinon, résultats ramenés à { value, errors, warnings } : un par élément d'un tableau, sinon un seul
    LET $states = array::map($outcomes, |$outcome, $position| {
        LET $key = $keys[$position];
        LET $many = type::is_array($outcome);
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
                value: IF $many { $value[$key][$index] } ELSE { $value[$key] },
                errors: [{ path: $path, rule: "check", code: $item.code, details: $item.details ?? {} }],
                warnings: []
            };
        });
        RETURN {
            value: IF $many { $lifted.value } ELSE { $lifted[0].value },
            errors: array::flatten($lifted.errors),
            warnings: array::flatten($lifted.warnings)
        };
    });
    LET $errors = array::concat(
        array::flatten($states.errors),
        array::map($unknown, |$key| { path: $key, rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: $key } })
    );
    RETURN {
        valid: array::is_empty($errors),
        value: object::from_entries(array::transpose([$keys, $states.value])[WHERE $this[1] IS NOT NONE]),
        errors: $errors,
        warnings: array::flatten($states.warnings),
        by_field: IF array::is_empty($errors) { {} } ELSE { fn::utils_engine_by_field($errors) }
    };
}
COMMENT "Rapport { valid, value, errors, warnings, by_field } d'un objet dont les champs ont déjà été contrôlés : $checks donne, par champ, le résultat d'un validateur du Core, le rapport d'un objet imbriqué, ou un tableau de l'un ou de l'autre (éléments d'un tableau) ; toute clé de $value absente de $checks est refusée. Même rapport que fn::validation_fields_execute en mode reject (au nom de règle près). Pour les fonctions du worker appelées par lots ; ailleurs, fn::validation_fields_execute."
PERMISSIONS FULL;
