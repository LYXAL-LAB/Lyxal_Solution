-- lyxal-test: assertions
-- Tests de fn::sanitize_e164 (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: national vers E.164
RETURN fn::sanitize_e164("06 12 34 56 78", "33") == "+33612345678";

-- test: déjà international
RETURN fn::sanitize_e164("+44 20 7946 0000", "33") == "+442079460000";

-- test: sans indicatif connu
RETURN fn::sanitize_e164("06 12", NONE) == "612";

-- test: indicatif avec +
RETURN fn::sanitize_e164("0612", "+33") == "+33612";

-- test: entrée absente → NONE
RETURN fn::sanitize_e164(NONE, "33") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_e164(NULL, "33");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_e164(42, "33");
