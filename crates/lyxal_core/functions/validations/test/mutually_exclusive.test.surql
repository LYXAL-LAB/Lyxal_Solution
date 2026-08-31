-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/mutually_exclusive.test.surql
-- Fonction     : fn::validation_mutually_exclusive
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Une seule valeur présente
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_mutually_exclusive(
    ["email@example.com", NONE, NONE],
    "CONTACT_METHOD",
    false
);

-- ============================================================================
-- TEST 2 — Aucune valeur autorisée
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_mutually_exclusive(
    [NONE, NONE, NONE],
    "CONTACT_METHOD",
    true
);

-- ============================================================================
-- TEST 3 — Deux valeurs présentes
-- Erreur attendue : CONTACT_METHOD_MUTUALLY_EXCLUSIVE
-- ============================================================================
RETURN fn::validation_mutually_exclusive(
    ["email@example.com", "+33123456789", NONE],
    "CONTACT_METHOD",
    false
);
