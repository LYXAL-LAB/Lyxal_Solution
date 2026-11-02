-- lyxal-test: assertions
-- Tests de fn::security_pipeline_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: masquage et détection
RETURN fn::security_pipeline_execute("<script>alert(1)</script> a@b.fr", [{ rule: "detect_xss" }, { rule: "redact_log" }], 10).findings[0].result.detected;

-- test: score de risque
RETURN fn::security_pipeline_execute("1 OR 1=1", [{ rule: "detect_payload" }], 10).score > 0;

-- test: permission refusée
RETURN fn::security_pipeline_execute(NONE, [{ rule: "permission_check", options: { permissions: [{ resource: "invoice", action: "read", effect: "allow" }], resource: "invoice", action: "delete" } }], 10).allowed == false;

-- test: each sur un tableau
RETURN fn::security_pipeline_execute(["a@b.fr", "c@d.fr"], [{ rule: "each", options: { pipeline: [{ rule: "redact_email" }] } }], 10).value == [fn::security_redact_email("a@b.fr"), fn::security_redact_email("c@d.fr")];

-- test: option obligatoire absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_pipeline_execute("a", [{ rule: "hash_string" }], 10);

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_pipeline_execute("a", [{ rule: "inconnue" }], 10);
