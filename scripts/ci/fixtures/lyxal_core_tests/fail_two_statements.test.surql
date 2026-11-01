-- lyxal-test: assertions

-- test: deux instructions dans un bloc
RETURN fn::selftest_add(1, 1) == 2;
RETURN fn::selftest_add(1, 2) == 3;
