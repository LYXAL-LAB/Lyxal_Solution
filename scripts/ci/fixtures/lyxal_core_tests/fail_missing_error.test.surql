-- lyxal-test: assertions

-- test: erreur annoncée mais absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::selftest_check(5);
