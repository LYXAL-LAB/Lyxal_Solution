-- lyxal-test: assertions
-- Tests de fn::security_hmac_headers (format : crates/lyxal_core/implementation_plan.md §5).

-- test: en-têtes triés et nettoyés
RETURN fn::security_hmac_headers({ host: " api.x ", date: "lundi" }, [" Host", "date"]) == "date:lundi\nhost:api.x";
