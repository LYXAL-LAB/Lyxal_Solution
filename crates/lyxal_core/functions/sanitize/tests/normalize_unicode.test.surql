-- lyxal-test: assertions
-- Tests de fn::sanitize_normalize_unicode (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espace insécable et invisible
RETURN fn::sanitize_normalize_unicode("a\u00A0b\u200Bc", false) == "a bc";

-- test: regroupement des espaces
RETURN fn::sanitize_normalize_unicode(" a\u2003\u2003b ", true) == "a b";

-- test: entrée absente → NONE
RETURN fn::sanitize_normalize_unicode(NONE, false) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_normalize_unicode(NULL, false);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_normalize_unicode(42, false);
