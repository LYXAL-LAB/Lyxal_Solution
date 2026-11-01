-- lyxal-test: assertions
-- Toutes les assertions de ce fichier doivent passer.

-- test: addition
RETURN fn::selftest_add(2, 3) == 5;

-- test: résultat complet
RETURN fn::selftest_check(42) == { valid: true, value: 42, code: NONE, details: {} };

-- test: résultat invalide
RETURN fn::selftest_check(3).code == "CORE_VALIDATION_TOO_SMALL";

-- test: erreur de programmation attendue
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::selftest_check(-1);
