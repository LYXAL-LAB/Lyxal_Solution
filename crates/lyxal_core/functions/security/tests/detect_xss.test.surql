-- lyxal-test: assertions
-- Tests de fn::security_detect_xss (format : crates/lyxal_core/implementation_plan.md §5).

-- test: balise script
RETURN fn::security_detect_xss("<SCRIPT>alert(1)</script>").score == 20;

-- test: gestionnaire et javascript:
RETURN fn::security_detect_xss("<a onclick=x href=javascript:y>").score == 40;

-- test: texte ordinaire
RETURN !fn::security_detect_xss("Un texte <b>gras</b>").detected;
