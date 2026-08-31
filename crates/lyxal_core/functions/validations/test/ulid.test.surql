-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ulid.test.surql
-- Fonction     : fn::validation_ulid
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — ULID valide
-- Résultat attendu : "01JCJB3TPQ50XTG32WM088NKJD"
-- ============================================================================
RETURN fn::validation_ulid(
    "01jcjb3tpq50xtg32wm088nkjd",
    "ULID"
);

-- ============================================================================
-- TEST 2 — Longueur invalide
-- Erreur attendue : ULID_INVALID_ULID
-- ============================================================================
RETURN fn::validation_ulid(
    "01JCJB3TPQ50XTG32WM088NKJ",
    "ULID"
);

-- ============================================================================
-- TEST 3 — Caractère interdit
-- Erreur attendue : ULID_INVALID_ULID
-- ============================================================================
RETURN fn::validation_ulid(
    "01JCJB3TPQ50XTG32WM088NKJI",
    "ULID"
);
