-- lyxal-test: assertions
-- Tests de fn::security_detect_report (format : crates/lyxal_core/implementation_plan.md §5).

-- test: niveau
RETURN fn::security_detect_report(" form ", [{ detected: true, score: 70 }, { detected: false, score: 0 }]).level == "high";

-- test: rien détecté
RETURN fn::security_detect_report("s", []).level == "none";
