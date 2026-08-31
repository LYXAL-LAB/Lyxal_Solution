-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/invoice_number.test.surql
-- Fonction     : fn::validation_invoice_number
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Numéro classique
RETURN fn::validation_invoice_number("FAC-2026-000123", "INVOICE_NUMBER", ["FAC-"], 5, 64);

-- TEST 2 — Format avec barres
RETURN fn::validation_invoice_number("2026/08/00123", "INVOICE_NUMBER", NONE, 5, 64);

-- TEST 3 — Préfixe interdit
-- Erreur attendue : INVOICE_NUMBER_PREFIX_NOT_ALLOWED
RETURN fn::validation_invoice_number("AVOIR-2026-001", "INVOICE_NUMBER", ["FAC-"], 5, 64);

-- TEST 4 — Espaces interdits
-- Erreur attendue : INVOICE_NUMBER_INVALID_INVOICE_NUMBER
RETURN fn::validation_invoice_number("FAC 2026 001", "INVOICE_NUMBER", NONE, 5, 64);
