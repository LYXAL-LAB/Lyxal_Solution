-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_event_name.test.surql
-- Fonction     : fn::validation_lyxal_event_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Événement valide
-- Résultat attendu : "booking.created"
-- ============================================================================
RETURN fn::validation_lyxal_event_name(
    "Booking.Created",
    "EVENT_NAME",
    2,
    5
);

-- ============================================================================
-- TEST 2 — Événement détaillé
-- Résultat attendu : "scheduler.job.execution.failed"
-- ============================================================================
RETURN fn::validation_lyxal_event_name(
    "scheduler.job.execution.failed",
    "EVENT_NAME",
    2,
    5
);

-- ============================================================================
-- TEST 3 — Trop peu de segments
-- Erreur attendue : EVENT_NAME_TOO_FEW_SEGMENTS
-- ============================================================================
RETURN fn::validation_lyxal_event_name(
    "created",
    "EVENT_NAME",
    2,
    5
);

-- ============================================================================
-- TEST 4 — Segment avec tiret
-- Erreur attendue : EVENT_NAME_INVALID_EVENT_NAME
-- ============================================================================
RETURN fn::validation_lyxal_event_name(
    "booking.payment-failed",
    "EVENT_NAME",
    2,
    5
);
