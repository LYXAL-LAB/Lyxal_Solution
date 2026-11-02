-- lyxal-test: assertions
-- Tests de fn::security_secret_strength (format : crates/lyxal_core/implementation_plan.md §5).

-- test: très fort
RETURN fn::security_secret_strength("Abcdefghij1!Abcdefghij") == { score: 4, level: "very_strong", length: 22, character_classes: 4 };

-- test: faible
RETURN fn::security_secret_strength("abc").level == "weak";
