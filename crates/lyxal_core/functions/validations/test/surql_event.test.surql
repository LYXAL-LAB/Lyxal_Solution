-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_event.test.surql
-- Fonction     : fn::validation_surql_event
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Événement valide
-- Résultat attendu : "sync_search_index"
-- ============================================================================
RETURN fn::validation_surql_event(
    "sync_search_index",
    "EVENT_NAME",
    128
);

-- ============================================================================
-- TEST 2 — Point interdit
-- Erreur attendue : EVENT_NAME_INVALID_EVENT_NAME
-- ============================================================================
RETURN fn::validation_surql_event(
    "user.created",
    "EVENT_NAME",
    128
);
