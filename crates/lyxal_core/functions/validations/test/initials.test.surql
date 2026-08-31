-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/initials.test.surql
-- Fonction     : fn::validation_initials
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Initiales simples
-- Résultat attendu : "YD"
-- ============================================================================
RETURN fn::validation_initials("Y.D.", "INITIALS", 1, 5);

-- ============================================================================
-- TEST 2 — Espaces acceptés
-- Résultat attendu : "JPL"
-- ============================================================================
RETURN fn::validation_initials("J P L", "INITIALS", 1, 5);

-- ============================================================================
-- TEST 3 — Chiffre interdit
-- Erreur attendue : INITIALS_INVALID_INITIALS
-- ============================================================================
RETURN fn::validation_initials("Y2", "INITIALS", 1, 5);
