-- lyxal-test: assertions

-- test: autre erreur que celle annoncée
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::selftest_check(-1);
