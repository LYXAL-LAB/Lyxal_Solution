-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/money.test.surql
-- Fonction     : fn::validation_money
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Montant valide à deux décimales
-- Résultat attendu : 19.99dec
-- ============================================================================
RETURN fn::validation_money(19.99dec, "PRICE", 0dec, NONE, 2);

-- ============================================================================
-- TEST 2 — Montant entier decimal
-- Résultat attendu : 20dec
-- ============================================================================
RETURN fn::validation_money(20dec, "PRICE", 0dec, NONE, 2);

-- ============================================================================
-- TEST 3 — Trop de décimales
-- Erreur attendue : PRICE_TOO_MANY_DECIMALS
-- ============================================================================
RETURN fn::validation_money(19.999dec, "PRICE", 0dec, NONE, 2);

-- ============================================================================
-- TEST 4 — Int refusé
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_money(20, "PRICE", 0dec, NONE, 2);

-- ============================================================================
-- TEST 5 — Montant négatif refusé par la borne
-- Erreur attendue : PRICE_TOO_SMALL
-- ============================================================================
RETURN fn::validation_money(-0.01dec, "PRICE", 0dec, NONE, 2);

-- ============================================================================
-- TEST 6 — Échelle invalide
-- Erreur attendue : VALIDATION_INVALID_MONEY_SCALE
-- ============================================================================
RETURN fn::validation_money(19.99dec, "PRICE", 0dec, NONE, -1);
