-- lyxal-test: assertions
-- Tests de fn::security_hash_object (format : crates/lyxal_core/implementation_plan.md §5).

-- test: objet canonique
RETURN fn::security_hash_object({ a: 1 }, "sha256") == { algorithm: "sha256", canonical: "{\"a\":1}", hash: "015abd7f5cc57a2dd94b7590f04ad8084273905ee33ec5cebeae62276a97f862" };

-- test: algorithme inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_hash_object({ a: 1 }, "md5");
