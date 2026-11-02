-- lyxal-test: assertions
-- Tests de fn::security_redact_log (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: jeton Bearer
RETURN fn::security_redact_log("GET /a authorization: bearer abc.def-123 ok") == "GET /a Authorization: Bearer ***REDACTED*** ok";

-- test: clé et mot de passe
RETURN fn::security_redact_log("API-KEY: k123, password=secret;fin") == "api_key=***REDACTED***, password=***REDACTED***;fin";

-- test: message sans secret
RETURN fn::security_redact_log("connexion réussie") == "connexion réussie";
