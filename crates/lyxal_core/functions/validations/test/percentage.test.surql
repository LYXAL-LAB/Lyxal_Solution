-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/percentage.test.surql
-- Fonction     : fn::validation_percentage
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Pourcentage valide
-- Résultat attendu : 20
-- ============================================================================
RETURN fn::validation_percentage(20, "DISCOUNT", 0, 100);

-- ============================================================================
-- TEST 2 — Borne minimale
-- Résultat attendu : 0
-- ============================================================================
RETURN fn::validation_percentage(0, "DISCOUNT", 0, 100);

-- ============================================================================
-- TEST 3 — Borne maximale
-- Résultat attendu : 100
-- ============================================================================
RETURN fn::validation_percentage(100, "DISCOUNT", 0, 100);

-- ============================================================================
-- TEST 4 — Trop élevé
-- Erreur attendue : DISCOUNT_TOO_LARGE
-- ============================================================================
RETURN fn::validation_percentage(100.01dec, "DISCOUNT", 0, 100);

-- ============================================================================
-- TEST 5 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_PERCENTAGE_RANGE
-- ============================================================================
RETURN fn::validation_percentage(50, "DISCOUNT", 100, 0);
