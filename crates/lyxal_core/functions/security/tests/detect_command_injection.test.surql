-- lyxal-test: assertions
-- Tests de fn::security_detect_command_injection (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: enchaînement de commande
RETURN fn::security_detect_command_injection("a.txt; curl http://x").detected;

-- test: substitution
RETURN fn::security_detect_command_injection("$(whoami)").score == 25;

-- test: texte ordinaire
RETURN !fn::security_detect_command_injection("devis du 3 mars").detected;
