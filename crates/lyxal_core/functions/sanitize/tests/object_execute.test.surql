-- lyxal-test: assertions
-- Tests de fn::sanitize_object_execute (format : crates/lyxal_core/implementation_plan.md §5).

-- test: champs nettoyés, défaut appliqué, clé inconnue retirée
RETURN fn::sanitize_object_execute({ name: " jean dupont ", extra: 1 }, { fields: { name: { pipeline: [{ rule: "trim" }, { rule: "title_case" }] }, lang: { pipeline: [{ rule: "lowercase" }], default: "FR" } }, unknown_keys: "strip" }, 10) == { name: "Jean Dupont", lang: "fr" };

-- test: NONE traversé
RETURN fn::sanitize_object_execute(NONE, { fields: { name: { pipeline: [{ rule: "trim" }, { rule: "title_case" }] }, lang: { pipeline: [{ rule: "lowercase" }], default: "FR" } }, unknown_keys: "strip" }, 10) IS NONE;

-- test: valeur qui n'est pas un objet
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_execute("a", { fields: { name: { pipeline: [{ rule: "trim" }, { rule: "title_case" }] }, lang: { pipeline: [{ rule: "lowercase" }], default: "FR" } }, unknown_keys: "strip" }, 10);

-- test: champ requis absent
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_execute({}, { fields: { name: { required: true } } }, 10);

-- test: schéma invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_object_execute({}, { fields: {} }, 10);
