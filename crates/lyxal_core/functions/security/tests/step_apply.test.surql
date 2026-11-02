-- lyxal-test: assertions
-- Tests de fn::security_step_apply (format : crates/lyxal_core/implementation_plan.md §5).

-- test: masquage
RETURN fn::security_step_apply(fn::utils_engine_state("jean.dupont@example.com", "", NONE), { rule: "redact_email", options: {} }).value == fn::security_redact_email("jean.dupont@example.com");

-- test: options par défaut
RETURN fn::security_step_apply(fn::utils_engine_state("sk_live_abcdef123456", "", NONE), { rule: "secret_mask", options: {} }).value == fn::security_secret_mask("sk_live_abcdef123456", 0, 4, "*");

-- test: détection enregistrée, valeur inchangée
RETURN fn::security_step_apply(fn::utils_engine_state("1 OR 1=1", "c", NONE), { rule: "detect_sql_injection", options: {} }).records[0].kind == "finding";

-- test: décision enregistrée
RETURN fn::security_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: "permission_check", options: { permissions: [{ resource: "invoice", action: "read", effect: "allow" }], resource: "invoice", action: "read" } }).records[0].data.allowed;

-- test: NONE traversé
RETURN fn::security_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: "redact_email", options: {} }).value IS NONE;

-- test: type inattendu
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_step_apply(fn::utils_engine_state(12, "", NONE), { rule: "redact_email", options: {} });

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_step_apply(fn::utils_engine_state("a", "", NONE), { rule: "inconnue", options: {} });
