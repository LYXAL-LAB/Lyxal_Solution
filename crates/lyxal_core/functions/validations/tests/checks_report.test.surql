-- lyxal-test: assertions
-- Tests de fn::validation_checks_report (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: objet valide, valeurs normalisées par les validateurs, champ facultatif absent omis
RETURN fn::validation_checks_report({ account: " mail_account:a ", size: 12 }, {
    account: fn::validation_record(" mail_account:a ", "mail_account"),
    size: fn::validation_integer(12, 1, 100),
    note: fn::validation_optional_string(NONE, NONE, 20)
}) == { valid: true, value: { account: mail_account:a, size: 12 }, errors: [], warnings: [], by_field: {} };

-- test: valeur par défaut posée par l'appelant, contrôlée comme une valeur donnée
RETURN array::map([{}, { language: "en" }, { language: "zz9" }], |$given| fn::validation_checks_report($given, {
    language: fn::validation_language_code(IF $given.language IS NONE { "fr" } ELSE { $given.language }, false, NONE)
}).{ valid, value, by_field }) == [
    { valid: true, value: { language: "fr" }, by_field: {} },
    { valid: true, value: { language: "en" }, by_field: {} },
    { valid: false, value: { language: "zz9" }, by_field: { language: ["CORE_VALIDATION_FORMAT"] } }
];

-- test: champ exigé absent (CORE_VALIDATION_REQUIRED) et NULL (CORE_VALIDATION_NULL), codes du validateur
RETURN fn::validation_checks_report({ size: NULL }, {
    account: fn::validation_record(NONE, "mail_account"),
    size: fn::validation_integer(NULL, 1, 100)
}) == { valid: false, value: { size: NULL }, errors: [
    { path: "account", rule: "check", code: "CORE_VALIDATION_REQUIRED", details: {} },
    { path: "size", rule: "check", code: "CORE_VALIDATION_NULL", details: {} }
], warnings: [], by_field: { account: ["CORE_VALIDATION_REQUIRED"], size: ["CORE_VALIDATION_NULL"] } };

-- test: erreur d'un validateur, avec son code et ses détails ; le champ en erreur garde la valeur reçue, les autres leur valeur normalisée
RETURN fn::validation_checks_report({ name: "abcdefghij", account: " mail_account:a " }, {
    name: fn::validation_max_length("abcdefghij", 5),
    account: fn::validation_record(" mail_account:a ", "mail_account")
}) == { valid: false, value: { name: "abcdefghij", account: mail_account:a },
    errors: [{ path: "name", rule: "check", code: "CORE_VALIDATION_TOO_LONG", details: { length: 10, max_length: 5 } }],
    warnings: [], by_field: { name: ["CORE_VALIDATION_TOO_LONG"] } };

-- test: contrôles enchaînés par l'appelant : le second reçoit la valeur normalisée par le premier, arrêt au premier en erreur
RETURN array::map(["  abc  ", "  abcdef  ", 3], |$given| {
    LET $text = fn::validation_required_string($given, 1, 64);
    RETURN fn::validation_checks_report({ name: $given }, { name: IF $text.valid { fn::validation_max_length($text.value, 3) } ELSE { $text } }).{ value, by_field };
}) == [
    { value: { name: "abc" }, by_field: {} },
    { value: { name: "  abcdef  " }, by_field: { name: ["CORE_VALIDATION_TOO_LONG"] } },
    { value: { name: 3 }, by_field: { name: ["CORE_VALIDATION_TYPE"] } }
];

-- test: clés inconnues refusées, après les erreurs des champs
RETURN fn::validation_checks_report({ size: 0, zeta: 1, alpha: 2 }, { size: fn::validation_integer(0, 1, 100) })
    == { valid: false, value: { size: 0 }, errors: [
        { path: "size", rule: "check", code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1 } },
        { path: "alpha", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "alpha" } },
        { path: "zeta", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "zeta" } }
    ], warnings: [], by_field: { size: ["CORE_VALIDATION_TOO_SMALL"], alpha: ["CORE_VALIDATION_NOT_ALLOWED"], zeta: ["CORE_VALIDATION_NOT_ALLOWED"] } };

-- test: clé inconnue seule, champs valides : valeur normalisée sans la clé inconnue
RETURN fn::validation_checks_report({ size: 5, extra: 1 }, { size: fn::validation_integer(5, 1, 100) })
    == { valid: false, value: { size: 5 }, errors: [{ path: "extra", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "extra" } }],
        warnings: [], by_field: { extra: ["CORE_VALIDATION_NOT_ALLOWED"] } };

-- test: valeur qui n'est pas un objet (erreur de fn::validation_object, chemin racine), résultats des champs ignorés
RETURN fn::validation_checks_report("abc", { size: fn::validation_integer(NONE, 1, 100) })
    == { valid: false, value: "abc", errors: [{ path: "", rule: "is_object", code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "string" } }], warnings: [], by_field: { "$": ["CORE_VALIDATION_TYPE"] } };

-- test: valeur absente, NULL, tableau
RETURN array::map([NONE, NULL, [1]], |$given| fn::validation_checks_report($given, { size: fn::validation_integer(5, 1, 100) }).by_field)
    == [{ "$": ["CORE_VALIDATION_REQUIRED"] }, { "$": ["CORE_VALIDATION_NULL"] }, { "$": ["CORE_VALIDATION_TYPE"] }];

-- test: objet imbriqué valide, sa valeur normalisée remplace celle du champ
RETURN fn::validation_checks_report({ owner: { account: " mail_account:a " } }, {
    owner: fn::validation_checks_report({ account: " mail_account:a " }, { account: fn::validation_record(" mail_account:a ", "mail_account") })
}) == { valid: true, value: { owner: { account: mail_account:a } }, errors: [], warnings: [], by_field: {} };

-- test: erreurs d'un objet imbriqué sous le chemin du champ
RETURN fn::validation_checks_report({ reception: { spf: "maybe", extra: 1 } }, {
    reception: fn::validation_checks_report({ spf: "maybe", extra: 1 }, {
        spf: fn::validation_enum("maybe", ["pass", "fail"], true),
        tls: fn::validation_boolean(NONE)
    })
}) == { valid: false, value: { reception: { spf: "maybe" } }, errors: [
    { path: "reception.spf", rule: "check", code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["pass", "fail"] } },
    { path: "reception.tls", rule: "check", code: "CORE_VALIDATION_REQUIRED", details: {} },
    { path: "reception.extra", rule: "unknown_keys", code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", key: "extra" } }
], warnings: [], by_field: { "reception.spf": ["CORE_VALIDATION_NOT_ALLOWED"], "reception.tls": ["CORE_VALIDATION_REQUIRED"], "reception.extra": ["CORE_VALIDATION_NOT_ALLOWED"] } };

-- test: objet imbriqué absent ou qui n'est pas un objet, erreur au chemin du champ
RETURN array::map([NONE, NULL, 3], |$given| fn::validation_checks_report({ reception: $given }, {
    reception: fn::validation_checks_report($given, { tls: fn::validation_boolean($given.tls) })
}).by_field) == [{ reception: ["CORE_VALIDATION_REQUIRED"] }, { reception: ["CORE_VALIDATION_NULL"] }, { reception: ["CORE_VALIDATION_TYPE"] }];

-- test: éléments d'un tableau valides, valeurs normalisées
RETURN fn::validation_checks_report({ items: [{ content: "mail_content:a" }, { content: " mail_content:b " }] }, {
    items: array::map([{ content: "mail_content:a" }, { content: " mail_content:b " }], |$item: any| fn::validation_checks_report($item, { content: fn::validation_record($item.content, "mail_content") }))
}) == { valid: true, value: { items: [{ content: mail_content:a }, { content: mail_content:b }] }, errors: [], warnings: [], by_field: {} };

-- test: erreurs des éléments d'un tableau sous le chemin de l'élément, objets imbriqués compris
{
    LET $given = { items: [{ content: "mail_content:a", reception: { tls: true } }, 3, { reception: { tls: "oui" } }] };
    RETURN fn::validation_checks_report($given, {
        items: array::map($given.items, |$item: any| fn::validation_checks_report($item, {
            content: fn::validation_record($item.content, "mail_content"),
            reception: fn::validation_checks_report($item.reception, { tls: fn::validation_boolean($item.reception.tls) })
        }))
    }) == { valid: false, value: { items: [{ content: mail_content:a, reception: { tls: true } }, 3, { reception: { tls: "oui" } }] }, errors: [
        { path: "items[1]", rule: "is_object", code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "int" } },
        { path: "items[2].content", rule: "check", code: "CORE_VALIDATION_REQUIRED", details: {} },
        { path: "items[2].reception.tls", rule: "check", code: "CORE_VALIDATION_TYPE", details: { expected: "bool", actual: "string" } }
    ], warnings: [], by_field: { "items[1]": ["CORE_VALIDATION_TYPE"], "items[2].content": ["CORE_VALIDATION_REQUIRED"], "items[2].reception.tls": ["CORE_VALIDATION_TYPE"] } };
};

-- test: tableau de résultats de validateurs, un par élément ; l'élément en erreur garde sa valeur
RETURN fn::validation_checks_report({ sizes: [5, 500, 7] }, { sizes: array::map([5, 500, 7], |$size: any| fn::validation_integer($size, 1, 100)) })
    == { valid: false, value: { sizes: [5, 500, 7] }, errors: [{ path: "sizes[1]", rule: "check", code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } }],
        warnings: [], by_field: { "sizes[1]": ["CORE_VALIDATION_TOO_LARGE"] } };

-- test: tableau vide de résultats
RETURN fn::validation_checks_report({ sizes: [] }, { sizes: [] }) == { valid: true, value: { sizes: [] }, errors: [], warnings: [], by_field: {} };

-- test: forme du tableau contrôlée d'abord par l'appelant : son erreur est celle du champ
{
    LET $sized = fn::validation_array_length([1, 2, 3], 1, 2);
    RETURN fn::validation_checks_report({ sizes: [1, 2, 3] }, { sizes: IF $sized.valid { array::map($sized.value, |$size: any| fn::validation_integer($size, 1, 100)) } ELSE { $sized } }).by_field
        == { sizes: ["CORE_VALIDATION_TOO_LONG"] };
};

-- test: avertissements d'un rapport imbriqué gardés, sous le chemin du champ, sans rendre l'objet invalide
RETURN fn::validation_checks_report({ a: { b: 1 } }, {
    a: { valid: true, value: { b: 1 }, errors: [], warnings: [{ path: "b", rule: "note", code: "CORE_NOTE", details: {} }, { path: "", rule: "note", code: "CORE_NOTE", details: {} }], by_field: {} }
}) == { valid: true, value: { a: { b: 1 } }, errors: [], warnings: [{ path: "a.b", rule: "note", code: "CORE_NOTE", details: {} }, { path: "a", rule: "note", code: "CORE_NOTE", details: {} }], by_field: {} };

-- test: rapport remis tel quel à fn::validation_fields_execute comme résultat d'un contrôle, élément par élément
RETURN fn::validation_fields_execute({ items: [{ size: 5 }, { size: 500 }] }, {
    items: { checks: [|$v: any| array::map($v, |$item: any| fn::validation_checks_report($item, { size: fn::validation_integer($item.size, 1, 100) }))], required: true }
}, "reject") == { valid: false, value: { items: [{ size: 5 }, { size: 500 }] },
    errors: [{ path: "items[1].size", rule: "check", code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } }],
    warnings: [], by_field: { "items[1].size": ["CORE_VALIDATION_TOO_LARGE"] } };

-- test: même rapport que fn::validation_fields_execute en mode reject (au nom de règle près)
RETURN array::all([
    { account: "mail_account:a", items: [{ content: "mail_content:a" }] },
    { account: " mail_account:a ", size: 50, items: [{ content: " mail_content:a " }, { content: "mail_content:b" }] },
    { account: "storage_object:a", size: 0, items: [{ content: 3, extra: true }, NULL], other: 1 },
    { account: NULL, items: [] },
    { size: NULL, items: "abc" },
    { items: [1, 2, 3, 4] },
    {},
    "abc",
    NULL
], |$case| {
    LET $fields = fn::validation_fields_execute($case, {
        account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
        size: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], default: 10 },
        items: { checks: [|$v: any| fn::validation_array_length($v, 1, 3), |$v: any| array::map($v, |$item: any| fn::validation_fields_execute($item, {
            content: { checks: [|$w: any| fn::validation_record($w, "mail_content")], required: true } }, "reject"))], required: true }
    }, "reject");
    LET $sized = fn::validation_array_length($case.items, 1, 3);
    LET $report = fn::validation_checks_report($case, {
        account: fn::validation_record($case.account, "mail_account"),
        size: fn::validation_integer(IF $case.size IS NONE { 10 } ELSE { $case.size }, 1, 100),
        items: IF $sized.valid { array::map($sized.value, |$item: any| fn::validation_checks_report($item, { content: fn::validation_record($item.content, "mail_content") })) } ELSE { $sized }
    });
    RETURN $fields.valid == $report.valid AND $fields.value == $report.value AND $fields.by_field == $report.by_field AND $fields.warnings == $report.warnings
        AND array::map($fields.errors, |$error| object::remove($error, "rule")) == array::map($report.errors, |$error| object::remove($error, "rule"));
});

-- test: aucun champ contrôlé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({}, {});

-- test: résultats contrôlés avant la valeur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report("abc", {});

-- test: résultat qui n'est pas celui d'un validateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({ size: 1 }, { size: true });

-- test: résultat absent
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({ size: 1 }, { size: NONE });

-- test: résultat sans booléen valid
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({ size: 1 }, { size: { valid: "true", value: 1 } });

-- test: élément de tableau qui n'est pas un résultat de validateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({ sizes: [1] }, { sizes: [1] });

-- test: résultat en erreur sans code
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_checks_report({ size: 1 }, { size: { valid: false } });
