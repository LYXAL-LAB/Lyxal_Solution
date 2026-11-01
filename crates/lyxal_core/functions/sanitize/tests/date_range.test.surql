-- lyxal-test: assertions
-- Tests de fn::sanitize_date_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans l'ordre
RETURN fn::sanitize_date_range(d"2026-01-01T00:00:00Z", d"2026-01-02T00:00:00Z", false) == { start: d"2026-01-01T00:00:00Z", end: d"2026-01-02T00:00:00Z" };

-- test: inversé si demandé
RETURN fn::sanitize_date_range(d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z", true) == { start: d"2026-01-01T00:00:00Z", end: d"2026-01-02T00:00:00Z" };

-- test: inversé sans permission
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_date_range(d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z", false);

-- test: borne absente → NONE
RETURN fn::sanitize_date_range(NONE, d"2026-01-01T00:00:00Z", true) == NONE;

-- test: borne de type chaîne
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_date_range("2026", d"2026-01-01T00:00:00Z", true);
