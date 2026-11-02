-- lyxal-test: assertions
-- Tests de fn::sanitize_array (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: tableau inchangé
RETURN fn::sanitize_array([1, 2]) == [1, 2];

-- test: valeur enveloppée
RETURN fn::sanitize_array("a") == ["a"];

-- test: NONE → tableau vide
RETURN fn::sanitize_array(NONE) == [];

-- test: NULL → tableau vide
RETURN fn::sanitize_array(NULL) == [];
