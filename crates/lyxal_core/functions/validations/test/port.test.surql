-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/port.test.surql
-- Fonction     : fn::validation_port
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Port HTTP
-- Résultat attendu : 80
-- ============================================================================
RETURN fn::validation_port(80, "PORT", 1, 65535);

-- ============================================================================
-- TEST 2 — Port maximal
-- Résultat attendu : 65535
-- ============================================================================
RETURN fn::validation_port(65535, "PORT", 1, 65535);

-- ============================================================================
-- TEST 3 — Port zéro interdit
-- Erreur attendue : PORT_PORT_TOO_LOW
-- ============================================================================
RETURN fn::validation_port(0, "PORT", 1, 65535);

-- ============================================================================
-- TEST 4 — Port trop élevé
-- Erreur attendue : PORT_PORT_TOO_HIGH
-- ============================================================================
RETURN fn::validation_port(65536, "PORT", 1, 65535);

-- ============================================================================
-- TEST 5 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_PORT_RANGE
-- ============================================================================
RETURN fn::validation_port(80, "PORT", 1000, 100);
