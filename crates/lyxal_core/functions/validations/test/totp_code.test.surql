-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/totp_code.test.surql
-- Fonction     : fn::validation_totp_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Code à 6 chiffres
-- Résultat attendu : "123456"
-- ============================================================================
RETURN fn::validation_totp_code("123456", "TOTP_CODE", 6);

-- ============================================================================
-- TEST 2 — Code à 8 chiffres
-- Résultat attendu : "12345678"
-- ============================================================================
RETURN fn::validation_totp_code("12345678", "TOTP_CODE", 8);

-- ============================================================================
-- TEST 3 — Longueur invalide
-- Erreur attendue : TOTP_CODE_INVALID_TOTP_CODE
-- ============================================================================
RETURN fn::validation_totp_code("12345", "TOTP_CODE", 6);

-- ============================================================================
-- TEST 4 — Lettres interdites
-- Erreur attendue : TOTP_CODE_INVALID_TOTP_CODE
-- ============================================================================
RETURN fn::validation_totp_code("12A456", "TOTP_CODE", 6);
