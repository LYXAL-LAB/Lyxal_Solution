-- lyxal-test: assertions
-- Tests de fn::security_detect_payload (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: plusieurs attaques
RETURN fn::security_detect_payload("<script>x</script> UNION SELECT a FROM b").detected;

-- test: six détecteurs
RETURN array::len(fn::security_detect_payload("x").results) == 6;

-- test: texte ordinaire
RETURN !fn::security_detect_payload("Bonjour").detected;
