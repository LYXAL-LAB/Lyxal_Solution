-- lyxal-test: assertions
-- Contrôle des messages ICU MessageFormat 1 : lecture (arguments, branches, apostrophes),
-- refus et avertissements par langue.

-- test: lecture des arguments, imbrication comprise
RETURN fn::i18n_message_inspect("Bonjour {name}, {count, plural, offset:1 =0 {rien} one {# article} other {# articles de {shop}}} le {day, date, short}.")
    == { balanced: true, arguments: [
        { name: "name", kind: "none", selectors: [] },
        { name: "shop", kind: "none", selectors: [] },
        { name: "count", kind: "plural", selectors: ["=0", "one", "other"] },
        { name: "day", kind: "date", selectors: [] }
    ] };

-- test: apostrophes d'échappement : texte littéral entre apostrophes, apostrophe doublée
RETURN fn::i18n_message_inspect("L''article '{exemple}' coûte {price, number} et c'est tout").arguments.name == ["price"]
    AND fn::i18n_message_inspect("'{' ouvert, {a} lu, '}' fermé").arguments.name == ["a"]
    AND fn::i18n_message_inspect("l'été {a}").arguments.name == ["a"];

-- test: accolades non équilibrées
RETURN !fn::i18n_message_inspect("a } b").balanced AND !fn::i18n_message_inspect("a {b").balanced
    AND !fn::i18n_message_inspect("{n, plural, one {x} other {y}").balanced
    AND fn::i18n_message_inspect("texte simple").balanced;

-- test: en-tête d'argument et avance d'un caractère
RETURN fn::i18n_message_argument("n, plural, offset:1", ["one"]) == { name: "n", kind: "plural", selectors: ["one"] }
    AND fn::i18n_message_step({ quote: false, pending: false, literal: false, frames: [], open_argument: false, arguments: [], balanced: true }, "}").balanced == false;

-- test: texte conforme, sans problème ni avertissement
RETURN fn::i18n_message_check({ text: "{n, plural, one {# jour} other {# jours}} pour {who}", syntax: "icu_mf1",
        params: [{ name: "n", type: "number" }, { name: "who", type: "string" }], locale: i18n_locale:en, max_length: NONE })
    == { problems: [], warnings: [] };

-- test: refus : accolades, argument invalide, inconnu, type non pris en charge
RETURN fn::i18n_message_check({ text: "a {b", syntax: "icu_mf1", params: [], locale: i18n_locale:fr, max_length: NONE }).problems == [{ code: "unbalanced_braces" }]
    AND fn::i18n_message_check({ text: "{0} et {b c}", syntax: "icu_mf1", params: [], locale: i18n_locale:fr, max_length: NONE }).problems
        == [{ code: "invalid_argument", argument: "0" }, { code: "invalid_argument", argument: "b c" }]
    AND fn::i18n_message_check({ text: "{x}", syntax: "icu_mf1", params: [], locale: i18n_locale:fr, max_length: NONE }).problems == [{ code: "unknown_argument", argument: "x" }]
    AND fn::i18n_message_check({ text: "{x, spellout}", syntax: "icu_mf1", params: [{ name: "x", type: "number" }], locale: i18n_locale:fr, max_length: NONE }).problems
        == [{ code: "unsupported_type", argument: "x", type: "spellout" }];

-- test: refus : type incompatible avec le paramètre déclaré
RETURN fn::i18n_message_check({ text: "{d, date} {n, number} {s, select, other {x}}", syntax: "icu_mf1",
        params: [{ name: "d", type: "string" }, { name: "n", type: "datetime" }, { name: "s", type: "number" }], locale: i18n_locale:fr, max_length: NONE }).problems
    == [{ code: "type_mismatch", argument: "d", type: "date", expected: "string" },
        { code: "type_mismatch", argument: "n", type: "number", expected: "datetime" },
        { code: "type_mismatch", argument: "s", type: "select", expected: "number" }];

-- test: refus : branche other absente (plural, selectordinal, select)
RETURN fn::i18n_message_check({ text: "{n, plural, one {x}} {o, selectordinal, one {x}} {s, select, a {x}}", syntax: "icu_mf1",
        params: [{ name: "n", type: "number" }, { name: "o", type: "number" }, { name: "s", type: "string" }], locale: i18n_locale:en, max_length: NONE }).problems
    == [{ code: "missing_other", argument: "n" }, { code: "missing_other", argument: "o" }, { code: "missing_other", argument: "s" }];

-- test: français : few inconnue (refus), many absente (avertissement), valeur exacte acceptée
RETURN fn::i18n_message_check({ text: "{n, plural, =0 {aucun} one {un} few {peu} other {des}}", syntax: "icu_mf1",
        params: [{ name: "n", type: "number" }], locale: i18n_locale:fr, max_length: NONE })
    == { problems: [{ code: "unknown_category", argument: "n", category: "few" }], warnings: [{ code: "missing_category", argument: "n", category: "many" }] };

-- test: anglais : ordinaux one, two, few, other ; cardinal sans avertissement
RETURN fn::i18n_message_check({ text: "{n, selectordinal, one {#st} two {#nd} few {#rd} other {#th}} {m, plural, one {x} other {y}}", syntax: "icu_mf1",
        params: [{ name: "n", type: "number" }, { name: "m", type: "number" }], locale: i18n_locale:en, max_length: NONE })
    == { problems: [], warnings: [] };

-- test: arabe : six catégories attendues, avertissement pour celles qui manquent
RETURN fn::i18n_message_check({ text: "{n, plural, zero {a} one {b} two {c} other {d}}", syntax: "icu_mf1",
        params: [{ name: "n", type: "number" }], locale: i18n_locale:ar, max_length: NONE })
    == { problems: [], warnings: [{ code: "missing_category", argument: "n", category: "few" }, { code: "missing_category", argument: "n", category: "many" }] };

-- test: polonais : one, few, many, other acceptées ; two refusée
RETURN fn::i18n_message_check({ text: "{n, plural, one {a} few {b} many {c} other {d}}", syntax: "icu_mf1", params: [{ name: "n", type: "number" }], locale: i18n_locale:pl, max_length: NONE })
        == { problems: [], warnings: [] }
    AND fn::i18n_message_check({ text: "{n, plural, two {a} other {d}}", syntax: "icu_mf1", params: [{ name: "n", type: "number" }], locale: i18n_locale:pl, max_length: NONE }).problems
        == [{ code: "unknown_category", argument: "n", category: "two" }];

-- test: longueur maximale ; texte plain non lu comme un message
RETURN fn::i18n_message_check({ text: "abcdef", syntax: "icu_mf1", params: [], locale: i18n_locale:fr, max_length: 5 }).problems == [{ code: "too_long", max_length: 5, length: 6 }]
    AND fn::i18n_message_check({ text: "f(x) = {x | x > 0", syntax: "plain", params: [{ name: "x", type: "number" }], locale: i18n_locale:fr, max_length: NONE }) == { problems: [], warnings: [] }
    AND fn::i18n_message_check({ text: "{abc", syntax: "plain", params: [], locale: i18n_locale:fr, max_length: 3 }).problems == [{ code: "too_long", max_length: 3, length: 4 }];

-- test: paramètre déclaré non utilisé : avertissement
RETURN fn::i18n_message_check({ text: "Bonjour", syntax: "icu_mf1", params: [{ name: "name", type: "string" }], locale: i18n_locale:fr, max_length: NONE })
    == { problems: [], warnings: [{ code: "unused_parameter", argument: "name" }] };
