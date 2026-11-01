-- lyxal-test: assertions

-- test: erreur non annoncée
RETURN fn::selftest_check(-1) == {};
