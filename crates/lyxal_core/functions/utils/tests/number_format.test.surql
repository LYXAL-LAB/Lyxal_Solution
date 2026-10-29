-- ============================================================================
-- TESTS — fn::utils_number_format
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Cas nominal avec décimales et séparateur de milliers
-- Résultat attendu : "1 234 567,80"
RETURN fn::utils_number_format(
    1234567.8f,
    2,
    ",",
    " "
);

-- TEST 2 — Précision nulle ($precision = 0)
-- Résultat attendu : "1 234 568"
RETURN fn::utils_number_format(
    1234567.8f,
    0,
    ",",
    " "
);

-- TEST 3 — Fraction plus longue que $precision (arrondi)
-- Résultat attendu : "1,234.57"
RETURN fn::utils_number_format(
    1234.56789,
    2,
    ".",
    ","
);

-- TEST 4 — Fraction avec zéro initial après la virgule (0.05)
-- Résultat attendu : "12,05"
RETURN fn::utils_number_format(
    12.05,
    2,
    ",",
    " "
);

-- TEST 5 — Valeur négative standard
-- Résultat attendu : "-987 654,30"
RETURN fn::utils_number_format(
    -987654.3,
    2,
    ",",
    " "
);

-- TEST 6 — Valeur négative arrondie à zéro (-0.001 -> "0,00" et non "-0,00")
-- Résultat attendu : "0,00"
RETURN fn::utils_number_format(
    -0.001,
    2,
    ",",
    " "
);

-- TEST 7 — Valeur nulle (0)
-- Résultat attendu : "0,00"
RETURN fn::utils_number_format(
    0,
    2,
    ",",
    " "
);

-- TEST 8 — Précision négative invalide
-- Erreur attendue : UTILS_INVALID_PRECISION
RETURN fn::utils_number_format(
    10,
    -1,
    ",",
    " "
);
