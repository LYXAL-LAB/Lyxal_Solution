-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/idempotency_key.test.surql
-- Fonction     : fn::validation_idempotency_key
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — UUID textuel
RETURN fn::validation_idempotency_key("0191f946-936f-7223-bef5-aebbc527ad80", "IDEMPOTENCY_KEY", 8, 255);

-- TEST 2 — Clé namespacée
RETURN fn::validation_idempotency_key("booking:create:abc_123", "IDEMPOTENCY_KEY", 8, 255);

-- TEST 3 — Espace interdit
-- Erreur attendue : IDEMPOTENCY_KEY_INVALID_IDEMPOTENCY_KEY
RETURN fn::validation_idempotency_key("booking create abc", "IDEMPOTENCY_KEY", 8, 255);
