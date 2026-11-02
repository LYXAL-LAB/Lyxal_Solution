-- lyxal-test: assertions
-- Tests de fn::security_redact_ip (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: IPv4
RETURN fn::security_redact_ip(" 192.168.1.42 ") == "192.168.x.x";

-- test: IPv6
RETURN fn::security_redact_ip("2001:db8:85a3:8d3:1319:8a2e") == "2001:db8:85a3:xxxx:xxxx:xxxx";

-- test: valeur invalide
RETURN fn::security_redact_ip("abc") == "***";
