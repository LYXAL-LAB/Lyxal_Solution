-- lyxal-test: assertions
-- Tests de fn::security_object_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: champs masqués, constats par champ
RETURN fn::security_object_execute({ email: "a@b.fr", note: "<script>x</script>" }, { fields: { email: { pipeline: [{ rule: "redact_email" }] }, note: { pipeline: [{ rule: "detect_xss" }] } } }, 10).findings.map(|$f| $f.path) == ["note"];

-- test: valeur masquée
RETURN fn::security_object_execute({ email: "a@b.fr" }, { fields: { email: { pipeline: [{ rule: "redact_email" }] } } }, 10).value.email == fn::security_redact_email("a@b.fr");

-- test: erreurs de schéma rapportées
RETURN fn::security_object_execute({ x: 1 }, { fields: { email: { required: true } } }, 10).errors.map(|$e| $e.code) == ["CORE_VALIDATION_REQUIRED", "CORE_VALIDATION_NOT_ALLOWED"];

-- test: schéma invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_object_execute({}, { fields: {} }, 10);
