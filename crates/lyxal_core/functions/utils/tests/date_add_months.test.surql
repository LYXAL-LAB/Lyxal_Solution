-- ============================================================================
-- TESTS — fn::utils_date_add_months
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Cas nominal (+2 mois)
RETURN fn::utils_date_add_months(
    d"2026-08-03T12:00:00Z",
    2
);

-- TEST 2 — Passage d'année (+5 mois depuis octobre)
RETURN fn::utils_date_add_months(
    d"2026-10-15T08:30:00Z",
    5
);

-- TEST 3 — Plafonnement fin de mois non bissextile (31 janvier 2026 + 1 mois -> 28 février 2026)
RETURN fn::utils_date_add_months(
    d"2026-01-31T12:00:00Z",
    1
);

-- TEST 4 — Plafonnement fin de mois bissextile (31 janvier 2024 + 1 mois -> 29 février 2024)
RETURN fn::utils_date_add_months(
    d"2024-01-31T12:00:00Z",
    1
);

-- TEST 5 — Soustraction de mois (-3 mois)
RETURN fn::utils_date_add_months(
    d"2026-02-15T12:00:00Z",
    -3
);
