-- lyxal-test: assertions
-- Tests de fn::sanitize_object_normalize (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: trois étapes
RETURN fn::sanitize_object_normalize({ name: "A", role: "admin", nickname: "" }, ["name", "language"], { language: "fr" }, true) == { name: "A", language: "fr" };

-- test: sans option
RETURN fn::sanitize_object_normalize({ a: "" }, NONE, NONE, false) == { a: "" };

-- test: entrée absente → NONE
RETURN fn::sanitize_object_normalize(NONE, ["name", "language"], { language: "fr" }, true) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_normalize(NULL, ["name", "language"], { language: "fr" }, true);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_normalize([1], ["name", "language"], { language: "fr" }, true);
