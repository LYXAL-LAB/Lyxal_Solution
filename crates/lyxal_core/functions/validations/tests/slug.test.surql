-- lyxal-test: assertions
-- Tests de fn::validation_slug (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: slug nettoyé et mis en minuscules
RETURN fn::validation_slug("  Mon-Article-2026 ", 120)
    == { valid: true, value: "mon-article-2026", code: NONE, details: {} };

-- test: sans longueur maximale
RETURN fn::validation_slug("a", NONE)
    == { valid: true, value: "a", code: NONE, details: {} };

-- test: double tiret refusé
RETURN fn::validation_slug("mon--article", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "slug" } };

-- test: tiret final refusé
RETURN fn::validation_slug("article-", NONE).code == "CORE_VALIDATION_FORMAT";

-- test: trop long
RETURN fn::validation_slug("abcdef", 5)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 5, length: 6 } };

-- test: chaîne blanche
RETURN fn::validation_slug(" ", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_slug(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_slug(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_slug(1, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_slug("a", 0);
