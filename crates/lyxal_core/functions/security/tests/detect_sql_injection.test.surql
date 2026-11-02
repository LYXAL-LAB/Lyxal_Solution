-- lyxal-test: assertions
-- Tests de fn::security_detect_sql_injection (format : crates/lyxal_core/implementation_plan.md §5).

-- test: UNION SELECT
RETURN fn::security_detect_sql_injection("1 UNION SELECT password FROM users") == { detected: true, category: "sql_injection", score: 40, matches: ["\\bunion\\s+select\\b", "\\bselect\\b.*\\bfrom\\b"] };

-- test: tautologie OR 1=1
RETURN fn::security_detect_sql_injection("x' OR 1=1 --").detected;

-- test: texte ordinaire
RETURN fn::security_detect_sql_injection("Bonjour, je voudrais réserver") == { detected: false, category: "sql_injection", score: 0, matches: [] };
