-- lyxal-test: assertions
-- Tests de fn::sanitize_replace_chars (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: caractères retirés
RETURN fn::sanitize_replace_chars("M.L.-x_y", [".", "-", "_"], NONE) == "MLxy";

-- test: caractères remplacés
RETURN fn::sanitize_replace_chars("M² et m³", NONE, [{ from: "²", to: "2" }, { from: "³", to: "3" }]) == "M2 et m3";

-- test: suppressions d'abord, puis remplacements dans l'ordre
RETURN fn::sanitize_replace_chars("a-b", ["-"], [{ from: "a", to: "b" }, { from: "b", to: "cc" }]) == "cccc";

-- test: remplacement par une chaîne vide ou de 8 caractères
RETURN fn::sanitize_replace_chars("a/b", [], [{ from: "/", to: "" }]) == "ab"
    AND fn::sanitize_replace_chars("a/b", [], [{ from: "/", to: "12345678" }]) == "a12345678b";

-- test: aucune expression régulière, casse respectée
RETURN fn::sanitize_replace_chars("a.b*C+c", [".", "*", "+", "c"], []) == "abC";

-- test: caractère absent : chaîne inchangée
RETURN fn::sanitize_replace_chars("abc", ["x"], [{ from: "y", to: "z" }]) == "abc";

-- test: chaîne vidée
RETURN fn::sanitize_replace_chars("...", ["."], NONE) == "";

-- test: règle du catalogue dans un pipeline
RETURN fn::sanitize_pipeline_execute(" m.l. ", [{ rule: "trim" }, { rule: "uppercase" }, { rule: "replace_chars", options: { remove: [".", "-", "_"] } }], 10) == "ML";

-- test: règle du catalogue dans un schéma d'objet
RETURN fn::sanitize_object_execute({ unit: "m_2" }, { fields: { unit: { pipeline: [{ rule: "replace_chars", options: { remove: ["_"], replace: [{ from: "m", to: "M" }] } }] } }, unknown_keys: "keep" }, 10) == { unit: "M2" };

-- test: entrée absente → NONE
RETURN fn::sanitize_replace_chars(NONE, ["."], NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_replace_chars(NULL, ["."], NONE);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_replace_chars(42, ["."], NONE);

-- test: aucune liste
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, NONE);

-- test: listes vides
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", [], []);

-- test: liste qui n'est pas un tableau
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", ".", NONE);

-- test: caractère à retirer de plusieurs caractères
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", ["ab"], NONE);

-- test: caractère à retirer vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", [""], NONE);

-- test: caractère à retirer qui n'est pas une chaîne
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", [1], NONE);

-- test: remplacement qui n'est pas un objet
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, ["a"]);

-- test: remplacement sans to
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, [{ from: "a" }]);

-- test: remplacement avec une clé inconnue
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, [{ from: "a", to: "b", regex: true }]);

-- test: from de plusieurs caractères
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, [{ from: "ab", to: "c" }]);

-- test: to de plus de 8 caractères
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_replace_chars("a", NONE, [{ from: "a", to: "123456789" }]);

-- test: option mal formée dans un pipeline, même sans valeur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_pipeline_execute(NONE, [{ rule: "replace_chars", options: { remove: "." } }], 10);

-- test: règle sans option dans un pipeline
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_pipeline_execute("a", [{ rule: "replace_chars" }], 10);
