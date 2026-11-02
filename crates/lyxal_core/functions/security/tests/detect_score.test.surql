-- lyxal-test: assertions
-- Tests de fn::security_detect_score (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: somme des scores
RETURN fn::security_detect_score([{ score: 20 }, { score: 30 }]) == 50;

-- test: plafond à 100
RETURN fn::security_detect_score([{ score: 70 }, { score: 60 }]) == 100;

-- test: liste vide
RETURN fn::security_detect_score([]) == 0;
