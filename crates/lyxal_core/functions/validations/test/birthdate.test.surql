-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/birthdate.test.surql
-- Fonction     : fn::validation_birthdate
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Date passée valide
-- Résultat attendu : date reçue
-- ============================================================================
RETURN fn::validation_birthdate(
    d"1980-05-10T00:00:00Z",
    "BIRTHDATE",
    false
);

-- ============================================================================
-- TEST 2 — Heure cachée
-- Erreur attendue : BIRTHDATE_INVALID_BIRTHDATE
-- ============================================================================
RETURN fn::validation_birthdate(
    d"1980-05-10T10:00:00Z",
    "BIRTHDATE",
    false
);

-- ============================================================================
-- TEST 3 — Date future
-- Erreur attendue : BIRTHDATE_FUTURE_BIRTHDATE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_birthdate(
    d"2100-01-01T00:00:00Z",
    "BIRTHDATE",
    false
);
