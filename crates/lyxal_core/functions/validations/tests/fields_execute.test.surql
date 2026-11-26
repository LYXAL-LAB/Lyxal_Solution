-- lyxal-test: assertions
-- Tests de fn::validation_fields_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: objet valide, valeurs normalisées par les validateurs, valeur par défaut posée
RETURN fn::validation_fields_execute({ account: " mail_account:a ", size: 12 }, {
    account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
    size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)] },
    note: { checks: [|$v: any| fn::validation_optional_string($v, NONE, 20)] },
    language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
}, "reject") == { valid: true, value: { account: mail_account:a, size: 12, language: "fr" }, errors: [], warnings: [], by_field: {} };

-- test: valeur donnée gardée, la valeur par défaut ne la remplace pas
RETURN fn::validation_fields_execute({ language: "en" }, { language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" } }, "reject").value == { language: "en" };

-- test: valeur par défaut contrôlée comme une valeur donnée
RETURN fn::validation_fields_execute({}, { size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], default: 500 } }, "reject").by_field == { size: ["CORE_VALIDATION_TOO_LARGE"] };

-- test: champ sans contrôle, valeur gardée telle quelle
RETURN fn::validation_fields_execute({ payload: { a: 1 } }, { payload: {}, other: {} }, "reject") == { valid: true, value: { payload: { a: 1 } }, errors: [], warnings: [], by_field: {} };

-- test: champ exigé absent (CORE_VALIDATION_REQUIRED)
RETURN fn::validation_fields_execute({}, { account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true } }, "reject")
    == { valid: false, value: {}, errors: [{ path: "account", rule: "required", code: "CORE_VALIDATION_REQUIRED", details: {} }], warnings: [], by_field: { account: ["CORE_VALIDATION_REQUIRED"] } };

-- test: NULL refusé (CORE_VALIDATION_NULL), même avec une valeur par défaut ; NULL gardé dans la valeur
RETURN fn::validation_fields_execute({ size: NULL }, { size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], default: 5 } }, "reject")
    == { valid: false, value: { size: NULL }, errors: [{ path: "size", rule: "nullable", code: "CORE_VALIDATION_NULL", details: {} }], warnings: [], by_field: { size: ["CORE_VALIDATION_NULL"] } };

-- test: NULL accepté par nullable, sans appeler les contrôles
RETURN fn::validation_fields_execute({ size: NULL }, { size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], nullable: true } }, "reject")
    == { valid: true, value: { size: NULL }, errors: [], warnings: [], by_field: {} };

-- test: erreur d'un validateur, avec son code, ses détails et le rang du contrôle
RETURN fn::validation_fields_execute({ name: "abcdefghij" }, {
    name: { checks: [|$v: any| fn::validation_required_string($v, 1, 64), |$v: any| fn::validation_max_length($v, 5)] }
}, "reject").errors == [{ path: "name", rule: "checks[1]", code: "CORE_VALIDATION_TOO_LONG", details: { length: 10, max_length: 5 } }];

-- test: arrêt au premier contrôle en erreur ; le champ garde la valeur d'avant ce contrôle
RETURN fn::validation_fields_execute({ name: "  abc  " }, {
    name: { checks: [|$v: any| fn::validation_required_string($v, 1, 64), |$v: any| fn::validation_max_length($v, 2), |$v: any| fn::validation_regex($v, "^[0-9]+$")] }
}, "reject") == { valid: false, value: { name: "abc" }, errors: [{ path: "name", rule: "checks[1]", code: "CORE_VALIDATION_TOO_LONG", details: { length: 3, max_length: 2 } }], warnings: [], by_field: { name: ["CORE_VALIDATION_TOO_LONG"] } };

-- test: un contrôle reçoit la valeur normalisée par le précédent
RETURN fn::validation_fields_execute({ name: "  abc  " }, {
    name: { checks: [|$v: any| fn::validation_required_string($v, 1, 64), |$v: any| fn::validation_max_length($v, 3)] }
}, "reject").value == { name: "abc" };

-- test: plusieurs champs en erreur, dans l'ordre des champs
RETURN fn::validation_fields_execute({ size: 0, role: "spam" }, {
    account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
    role: { checks: [|$v: any| fn::validation_enum($v, ["inbox", "junk"], true)] },
    size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)] }
}, "reject").by_field == { account: ["CORE_VALIDATION_REQUIRED"], role: ["CORE_VALIDATION_NOT_ALLOWED"], size: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: clés inconnues refusées (reject), après les erreurs des champs
RETURN fn::validation_fields_execute({ size: 0, zeta: 1, alpha: 2 }, { size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)] } }, "reject")
    == { valid: false, value: { size: 0 }, errors: [
        { path: "size", rule: "checks[0]", code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1 } },
        { path: "alpha", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "alpha" } },
        { path: "zeta", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "zeta" } }
    ], warnings: [], by_field: { size: ["CORE_VALIDATION_TOO_SMALL"], alpha: ["CORE_VALIDATION_NOT_ALLOWED"], zeta: ["CORE_VALIDATION_NOT_ALLOWED"] } };

-- test: clés inconnues retirées (strip)
RETURN fn::validation_fields_execute({ size: 5, extra: 1 }, { size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)] } }, "strip")
    == { valid: true, value: { size: 5 }, errors: [], warnings: [], by_field: {} };

-- test: clés inconnues gardées (keep), champs connus normalisés
RETURN fn::validation_fields_execute({ account: " mail_account:a ", extra: 1 }, { account: { checks: [|$v: any| fn::validation_record($v, "mail_account")] } }, "keep")
    == { valid: true, value: { account: mail_account:a, extra: 1 }, errors: [], warnings: [], by_field: {} };

-- test: valeur qui n'est pas un objet (erreur de fn::validation_object, chemin racine)
RETURN fn::validation_fields_execute("abc", { size: {} }, "reject")
    == { valid: false, value: "abc", errors: [{ path: "", rule: "is_object", code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "string" } }], warnings: [], by_field: { "$": ["CORE_VALIDATION_TYPE"] } };

-- test: valeur absente
RETURN fn::validation_fields_execute(NONE, { size: {} }, "reject").by_field == { "$": ["CORE_VALIDATION_REQUIRED"] };

-- test: valeur NULL
RETURN fn::validation_fields_execute(NULL, { size: {} }, "reject").by_field == { "$": ["CORE_VALIDATION_NULL"] };

-- test: tableau à la place d'un objet
RETURN fn::validation_fields_execute([1], { size: {} }, "keep").errors[0].details == { expected: "object", actual: "array" };

-- test: objet imbriqué valide, sa valeur normalisée remplace celle du champ
RETURN fn::validation_fields_execute({ owner: { account: " mail_account:a " } }, {
    owner: { checks: [|$v: any| fn::validation_fields_execute($v, { account: { checks: [|$w: any| fn::validation_record($w, "mail_account")], required: true }, role: { default: "inbox" } }, "reject")], required: true }
}, "reject") == { valid: true, value: { owner: { account: mail_account:a, role: "inbox" } }, errors: [], warnings: [], by_field: {} };

-- test: erreurs d'un objet imbriqué sous le chemin du champ
RETURN fn::validation_fields_execute({ reception: { spf: "maybe", extra: 1 } }, {
    reception: { checks: [|$v: any| fn::validation_fields_execute($v, {
        spf: { checks: [|$w: any| fn::validation_enum($w, ["pass", "fail"], true)], required: true },
        tls: { checks: [|$w: any| fn::validation_boolean($w)], required: true }
    }, "reject")], required: true }
}, "reject") == { valid: false, value: { reception: { spf: "maybe" } }, errors: [
    { path: "reception.spf", rule: "checks[0]", code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["pass", "fail"] } },
    { path: "reception.tls", rule: "required", code: "CORE_VALIDATION_REQUIRED", details: {} },
    { path: "reception.extra", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "extra" } }
], warnings: [], by_field: { "reception.spf": ["CORE_VALIDATION_NOT_ALLOWED"], "reception.tls": ["CORE_VALIDATION_REQUIRED"], "reception.extra": ["CORE_VALIDATION_NOT_ALLOWED"] } };

-- test: objet imbriqué qui n'est pas un objet, erreur au chemin du champ
RETURN fn::validation_fields_execute({ reception: 3 }, {
    reception: { checks: [|$v: any| fn::validation_fields_execute($v, { tls: {} }, "reject")] }
}, "reject").errors == [{ path: "reception", rule: "is_object", code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "int" } }];

-- test: éléments d'un tableau valides, valeurs normalisées
RETURN fn::validation_fields_execute({ items: [{ content: "mail_content:a" }, { content: "mail_content:b", role: "junk" }] }, {
    items: { checks: [|$v: any| fn::validation_array_length($v, 1, 3), |$v: any| array::map($v, |$item: any| fn::validation_fields_execute($item, {
        content: { checks: [|$w: any| fn::validation_record($w, "mail_content")], required: true },
        role: { checks: [|$w: any| fn::validation_enum($w, ["inbox", "junk"], true)], default: "inbox" }
    }, "reject"))], required: true }
}, "reject") == { valid: true, value: { items: [{ content: mail_content:a, role: "inbox" }, { content: mail_content:b, role: "junk" }] }, errors: [], warnings: [], by_field: {} };

-- test: erreurs des éléments d'un tableau sous le chemin de l'élément, objets imbriqués compris
RETURN fn::validation_fields_execute({ items: [{ content: "mail_content:a", reception: { tls: true } }, 3, { reception: { tls: "oui" } }] }, {
    items: { checks: [|$v: any| array::map($v, |$item: any| fn::validation_fields_execute($item, {
        content: { checks: [|$w: any| fn::validation_record($w, "mail_content")], required: true },
        reception: { checks: [|$w: any| fn::validation_fields_execute($w, { tls: { checks: [|$x: any| fn::validation_boolean($x)], required: true } }, "reject")], required: true }
    }, "reject"))] }
}, "reject") == { valid: false, value: { items: [{ content: mail_content:a, reception: { tls: true } }, 3, { reception: { tls: "oui" } }] }, errors: [
    { path: "items[1]", rule: "is_object", code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "int" } },
    { path: "items[2].content", rule: "required", code: "CORE_VALIDATION_REQUIRED", details: {} },
    { path: "items[2].reception.tls", rule: "checks[0]", code: "CORE_VALIDATION_TYPE", details: { expected: "bool", actual: "string" } }
], warnings: [], by_field: { "items[1]": ["CORE_VALIDATION_TYPE"], "items[2].content": ["CORE_VALIDATION_REQUIRED"], "items[2].reception.tls": ["CORE_VALIDATION_TYPE"] } };

-- test: tableau de résultats de validateurs, un par élément ; l'élément en erreur garde sa valeur
RETURN fn::validation_fields_execute({ sizes: [5, 500, 7] }, {
    sizes: { checks: [|$v: any| fn::validation_array($v), |$v: any| array::map($v, |$item: any| fn::validation_integer($item, 1, 100))] }
}, "reject") == { valid: false, value: { sizes: [5, 500, 7] }, errors: [
    { path: "sizes[1]", rule: "checks[1]", code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } }
], warnings: [], by_field: { "sizes[1]": ["CORE_VALIDATION_TOO_LARGE"] } };

-- test: tableau vide de résultats
RETURN fn::validation_fields_execute({ sizes: [] }, { sizes: { checks: [|$v: any| array::map($v, |$item: any| fn::validation_integer($item, 1, 100))] } }, "reject")
    == { valid: true, value: { sizes: [] }, errors: [], warnings: [], by_field: {} };

-- test: avertissements d'un rapport imbriqué gardés, sous le chemin du champ, sans arrêter les contrôles
RETURN fn::validation_fields_execute({ a: { b: 1 } }, {
    a: { checks: [
        |$v: any| { valid: true, value: $v, errors: [], warnings: [{ path: "b", rule: "note", code: "CORE_NOTE", details: {} }, { path: "", rule: "note", code: "CORE_NOTE", details: {} }], by_field: {} },
        |$v: any| fn::validation_object_non_empty($v)
    ] }
}, "reject") == { valid: true, value: { a: { b: 1 } }, errors: [], warnings: [{ path: "a.b", rule: "note", code: "CORE_NOTE", details: {} }, { path: "a", rule: "note", code: "CORE_NOTE", details: {} }], by_field: {} };

-- test: même rapport que fn::validation_object_execute (au nom de règle près)
RETURN array::all([
    { account: "mail_account:a", items: [{ content: "mail_content:a" }] },
    { account: "storage_object:a", size: 0, items: [{ content: 3, extra: true }, NULL], other: 1 },
    { account: NULL, items: [] },
    "abc"
], |$case| array::all(["reject", "strip", "keep"], |$mode| {
    LET $engine = fn::validation_object_execute($case, { fields: {
        account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
        size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 10 },
        items: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 3 } }, { rule: "each", options: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
            fields: { content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true } }, unknown_keys: "reject" } } }] } }] }
    }, unknown_keys: $mode }, 20);
    LET $fields = fn::validation_fields_execute($case, {
        account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
        size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], default: 10 },
        items: { checks: [|$v: any| fn::validation_array_length($v, 1, 3), |$v: any| array::map($v, |$item: any| fn::validation_fields_execute($item, {
            content: { checks: [|$w: any| fn::validation_record($w, "mail_content")], required: true } }, "reject"))] }
    }, $mode);
    RETURN !$engine.valid == !$fields.valid AND $engine.value == $fields.value AND $engine.by_field == $fields.by_field AND $engine.warnings == $fields.warnings
        AND array::map($engine.errors, |$error| object::remove($error, "rule")) == array::map($fields.errors, |$error| object::remove($error, "rule"));
}));

-- test: aucun champ déclaré
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, {}, "reject");

-- test: définitions contrôlées avant la valeur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute("abc", {}, "reject");

-- test: définition qui n'est pas un objet
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, { size: true }, "reject");

-- test: required qui n'est pas un booléen
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, { size: { required: "yes" } }, "reject");

-- test: required qui porte le nom d'une clé de définition
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, { size: { required: "default" } }, "reject");

-- test: nullable qui n'est pas un booléen
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, { size: { nullable: 1 } }, "reject");

-- test: clé inconnue dans une définition
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({}, { size: { requis: true } }, "reject");

-- test: checks qui n'est pas un tableau
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({ size: 1 }, { size: { checks: |$v: any| fn::validation_integer($v, 1, 100) } }, "reject");

-- test: contrôle qui ne rend pas un résultat de validateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({ size: 1 }, { size: { checks: [|$v: any| $v > 0] } }, "reject");

-- test: élément de tableau qui n'est pas un résultat de validateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({ sizes: [1] }, { sizes: { checks: [|$v: any| array::map($v, |$item: any| $item)] } }, "reject");

-- test: résultat en erreur sans code
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_fields_execute({ size: 1 }, { size: { checks: [|$v: any| { valid: false }] } }, "reject");

-- test: politique de clés inconnues invalide
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_fields_execute({}, { size: {} }, "ignore");
