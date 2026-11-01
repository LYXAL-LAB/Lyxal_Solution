-- lyxal-test: assertions
-- Tests de fn::sanitize_slug (format : crates/lyxal_core/implementation_plan.md §5).

-- test: titre accentué
RETURN fn::sanitize_slug("  Été 2026 : Lyxal OS !  ", "-") == "t-2026-lyxal-os";

-- test: tirets d'extrémité
RETURN fn::sanitize_slug("--a--b--", "-") == "a-b";

-- test: séparateur souligné
RETURN fn::sanitize_slug("Lyxal OS", "_") == "lyxal_os";

-- test: séparateur vide = tiret
RETURN fn::sanitize_slug("Lyxal OS", "") == "lyxal-os";

-- test: séparateur non pris en charge
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_slug("a b", ".");

-- test: entrée absente → NONE
RETURN fn::sanitize_slug(NONE, "-") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_slug(NULL, "-");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_slug(42, "-");
