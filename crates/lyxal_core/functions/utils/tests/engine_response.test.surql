-- lyxal-test: assertions
-- Tests de fn::utils_engine_response (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: réponse
RETURN fn::utils_engine_response({ request_id: u"0190e3b1-0000-7000-8000-000000000000", operation: "v", received_at: d"2026-01-01T00:00:00Z" }, "ok", d"2026-01-01T00:00:01Z").duration == 1s;

-- test: fin avant réception
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_response({ received_at: d"2026-01-02T00:00:00Z" }, 1, d"2026-01-01T00:00:00Z");
