-- lyxal-test: assertions
-- Tests de fn::security_detect_header_injection (format : crates/lyxal_core/implementation_plan.md §5).

-- test: retour à la ligne
RETURN fn::security_detect_header_injection("x\r\nSet-Cookie: a").score == 60;

-- test: forme encodée
RETURN fn::security_detect_header_injection("x%0d%0aSet-Cookie").detected;

-- test: valeur ordinaire
RETURN !fn::security_detect_header_injection("text/html").detected;
