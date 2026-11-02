-- lyxal-test: assertions
-- Tests de fn::sanitize_default_values (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: clés existantes conservées
RETURN fn::sanitize_default_values({ name: "A", theme: "dark" }, { language: "fr", theme: "light" }) == { name: "A", theme: "dark", language: "fr" };

-- test: clé NONE complétée
RETURN fn::sanitize_default_values({ language: NONE }, { language: "fr", theme: "light" }) == { language: "fr", theme: "light" };

-- test: entrée absente → NONE
RETURN fn::sanitize_default_values(NONE, { language: "fr", theme: "light" }) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_default_values(NULL, { language: "fr", theme: "light" });

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_default_values([1], { language: "fr", theme: "light" });
