-- lyxal-test: assertions
-- Tests de fn::security_hmac_payload (format : crates/lyxal_core/implementation_plan.md §5).

-- test: JSON
RETURN fn::security_hmac_payload({ a: 1 }, "application/json") == "{\"a\":1}";

-- test: texte brut
RETURN fn::security_hmac_payload("brut", "text/plain") == "brut";

-- test: objet hors JSON
RETURN fn::security_hmac_payload({ a: 1 }, "text/plain") == "{\"a\":1}";
