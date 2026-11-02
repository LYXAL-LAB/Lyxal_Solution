-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_event_handlers (format : crates/lyxal_core/implementation_plan.md §5).

-- test: onclick retiré
RETURN fn::sanitize_strip_event_handlers("<a href=\"/x\" onclick=\"alert(1)\">x</a>") == "<a href=\"/x\">x</a>";

-- test: onload sans guillemets
RETURN fn::sanitize_strip_event_handlers("<img src=a.png onload=go()>") == "<img src=a.png>";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_event_handlers(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_event_handlers(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_event_handlers(42);
