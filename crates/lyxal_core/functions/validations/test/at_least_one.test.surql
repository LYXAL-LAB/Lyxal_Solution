-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/at_least_one.test.surql
-- Fonction     : fn::validation_at_least_one
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Une valeur présente
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_at_least_one(
    [NONE, "email@example.com", NONE],
    "CONTACT"
);

-- ============================================================================
-- TEST 2 — Plusieurs valeurs présentes
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_at_least_one(
    ["email@example.com", "+33123456789"],
    "CONTACT"
);

-- ============================================================================
-- TEST 3 — Aucune valeur
-- Erreur attendue : CONTACT_AT_LEAST_ONE_REQUIRED
-- ============================================================================
RETURN fn::validation_at_least_one(
    [NONE, NONE],
    "CONTACT"
);
