-- ============================================================================
-- TESTS — fn::utils_date_end_of_month
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Mois de 31 jours (août)
RETURN fn::utils_date_end_of_month(
    d"2026-08-18T12:00:00Z"
);

-- TEST 2 — Décembre (bascule vers janvier N+1)
RETURN fn::utils_date_end_of_month(
    d"2026-12-10T00:00:00Z"
);

-- TEST 3 — Février année non bissextile (2026 -> 28 février)
RETURN fn::utils_date_end_of_month(
    d"2026-02-05T12:00:00Z"
);

-- TEST 4 — Février année bissextile (2024 -> 29 février)
RETURN fn::utils_date_end_of_month(
    d"2024-02-05T12:00:00Z"
);
