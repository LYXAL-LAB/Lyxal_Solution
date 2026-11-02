-- lyxal-test: assertions
-- Tests de fn::security_detect_open_redirect (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: URL externe
RETURN fn::security_detect_open_redirect(" HTTPS://evil.com ") == { detected: true, category: "open_redirect", score: 70, input: "https://evil.com" };

-- test: double barre
RETURN fn::security_detect_open_redirect("//evil.com").detected;

-- test: chemin interne
RETURN !fn::security_detect_open_redirect("/compte").detected;
