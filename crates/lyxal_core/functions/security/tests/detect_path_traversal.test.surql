-- lyxal-test: assertions
-- Tests de fn::security_detect_path_traversal (format : crates/lyxal_core/implementation_plan.md §5).

-- test: remontée et /etc/passwd
RETURN fn::security_detect_path_traversal("../../etc/passwd").score == 50;

-- test: forme encodée
RETURN fn::security_detect_path_traversal("%2E%2E%2Fsecret").detected;

-- test: chemin ordinaire
RETURN !fn::security_detect_path_traversal("docs/2026/rapport.pdf").detected;
