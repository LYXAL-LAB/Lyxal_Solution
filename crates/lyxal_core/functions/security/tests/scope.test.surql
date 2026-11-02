-- lyxal-test: assertions
-- Tests de fn::security_scope (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: scope normalisé
RETURN fn::security_scope(" Booking:Read ") == "booking:read";

-- test: sans séparateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_scope("booking");
